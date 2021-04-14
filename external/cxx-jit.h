#pragma once

#include <string>
#include <vector>

#include "clang/Basic/Stack.h"
#include "clang/Basic/TargetOptions.h"
#include "clang/Config/config.h"
#include "clang/Driver/DriverDiagnostic.h"
#include "clang/Driver/Options.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/FrontendDiagnostic.h"
#include "clang/Frontend/TextDiagnosticBuffer.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "clang/Frontend/Utils.h"
#include "clang/FrontendTool/Utils.h"
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/InitLLVM.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ADT/SmallString.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/Bitcode/BitcodeReader.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/MemoryBuffer.h>

#define STRLIT(A) #A
#define STRVAR(A) STRLIT(A)

static char ccstr[] = STRVAR(CXXJIT_ARGS) " -emit-llvm-bc";
static char *ccarg[128];
int nccarg = []() {
    int pos = 0;
    bool quot = false;
    ccarg[pos++] = ccstr;
    for (size_t i = 0; i < sizeof(ccstr); i++)
        if (ccstr[i] == '"') quot = !quot;
        else if (ccstr[i] == ' ' and !quot) {
            ccstr[ccstr[i-1] == '"' ? (i-1) : i] = '\0';
            ccarg[pos++] = ccstr + i + (ccstr[i+1] == '"' ? 2 : 1);
        }
    return pos;
}();


static void LLVMErrorHandler(void *UserData, const std::string &Message, bool GenCrashDiag);

class CxxJIT {
    public:
        
        CxxJIT() {
            llvm::InitializeNativeTarget();
            llvm::InitializeNativeTargetAsmPrinter();
            ctx = std::make_unique<llvm::LLVMContext>();
            jit = cantFail(llvm::orc::LLJITBuilder().create());
            Clang = std::make_unique<clang::CompilerInstance>();
            jit->getMainJITDylib().addGenerator(cantFail(
                llvm::orc::DynamicLibrarySearchGenerator::GetForCurrentProcess(jit->getDataLayout().getGlobalPrefix())));
        }
        
        ~CxxJIT() {
            for (auto d : deleters) d();
        }
        
        
        bool compile(std::string src) {
            using llvm::sys::fs::createTemporaryFile;
            int fd;
            llvm::SmallString<128> name;
            if (auto ec = createTemporaryFile("cxx-jit", "cpp", fd, name)) {
                errors.push_back(ec.message());
                return false;
            }
            
            constexpr bool shouldClose = true;
            constexpr bool unbuffered = true;
            llvm::raw_fd_ostream os(fd, shouldClose, unbuffered);
            os << src;
            llvm::StringRef inFileName = name.str();
            std::string inFname = inFileName.str();
            std::string bc = name.substr(0, inFileName.find_last_of('.') + 1).str() + "bc";
            
            if (!genByteCode(inFname, name.substr(0, inFileName.find_last_of('.') + 1).str() + "bc")) {
                errors.push_back("compilation error. skipping linking stage");
                return false;
            }
            
            llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>> buffer = llvm::MemoryBuffer::getFile(bc);
            if (!buffer) {
                errors.push_back(buffer.getError().message());
                return false;
            }
            
            auto module = parseBitcodeFile(buffer.get()->getMemBufferRef(), *ctx);
            
            llvm::sys::fs::remove(bc);
            
            if (!module) {
                llvm::sys::fs::remove(inFileName.str());
                llvm::Error err = module.takeError();
                llvm::handleAllErrors(std::move(err), [&](const llvm::StringError &strErr) {
                    errors.push_back("error creating module: " + strErr.getMessage());
                });
                return false;
            }
            
            deleters.push_back([inFname]() { llvm::sys::fs::remove(inFname); });
            
            return !jit->addIRModule(llvm::orc::ThreadSafeModule(std::move(*module), std::move(ctx)));
            
        }
        
        void *getSym(std::string name) {
            auto sym = jit->lookup(name);
            
            if (!sym) {
                errors.push_back("could not find " + name + " in symbol tables, but dumped them to stderr");
                jit->getExecutionSession().dump(llvm::errs());
                return nullptr;
            }
            return (void*)sym->getAddress();
        }
        
        void setSym(std::string name, void *addr) {
            llvm::orc::SymbolMap syms;
            syms[jit->getExecutionSession().intern(name)] =
                llvm::JITEvaluatedSymbol(llvm::pointerToJITTargetAddress(addr), llvm::JITSymbolFlags());
            jit->getMainJITDylib().define(absoluteSymbols(syms));
            
        }
               
        void addDylib(std::string filename) {
            char prefix = jit->getDataLayout().getGlobalPrefix();
            jit->getMainJITDylib().addGenerator(cantFail(llvm::orc::DynamicLibrarySearchGenerator::Load(filename.data(), prefix)));
        }
                  

        std::string errorString() {
            std::string s;
            for (const auto &e : errors) s += e+"\n";
            return s;
        }
        
        void handleLLVMErr(std::string msg) {
            errors.push_back("fatal compiler message: " + msg);
        }
        
    private:
        std::unique_ptr<llvm::LLVMContext> ctx;
        std::unique_ptr<llvm::orc::LLJIT> jit;
        
        std::vector<std::function<void()>> deleters;
        std::unique_ptr<clang::CompilerInstance> Clang;
        std::vector<std::string> errors;
        
        
        bool genByteCode(std::string inFileName, std::string outFileName) {
            clang::IntrusiveRefCntPtr<clang::DiagnosticIDs> diagId(new clang::DiagnosticIDs());
            clang::IntrusiveRefCntPtr<clang::DiagnosticOptions> diagOpts = new clang::DiagnosticOptions();
            clang::TextDiagnosticBuffer *diagBuf = new clang::TextDiagnosticBuffer;
            clang::DiagnosticsEngine diag(diagId, &*diagOpts, diagBuf);
            
            std::vector<const char *> argv(ccarg, ccarg + nccarg);
            argv.push_back(inFileName.data());
            argv.push_back("-o");
            argv.push_back(outFileName.data());
            bool Success = clang::CompilerInvocation::CreateFromArgs(Clang->getInvocation(), argv, diag);
            if (!Success) errors.push_back("Could not invoke compiler");
            
            Clang->createDiagnostics();
            if (!Clang->hasDiagnostics()) {
                errors.push_back("!Clang->hasDiagnostics");
                return false;
            }
            
            llvm::install_fatal_error_handler(LLVMErrorHandler, static_cast<void*>(this));
            diagBuf->FlushDiagnostics(Clang->getDiagnostics());
            if (!Success) return false;
            Success = ExecuteCompilerInvocation(Clang.get());
            llvm::remove_fatal_error_handler();
            return Success;
        }
        
};


static void LLVMErrorHandler(void *UserData, const std::string &Message, bool GenCrashDiag) {
    CxxJIT *jit = (CxxJIT*) UserData;
    jit->handleLLVMErr(Message);
}   






