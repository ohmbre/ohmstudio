#pragma once

#include <fstream>
#include <string>
#include <vector>
#include <filesystem>

#include "clang/Driver/Driver.h"
#include "clang/Driver/Compilation.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/TextDiagnosticBuffer.h"
#include "clang/FrontendTool/Utils.h"
#include <llvm/ExecutionEngine/Orc/LLJIT.h>
#include <llvm/Support/InitLLVM.h>
#include <llvm/Support/Host.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ADT/SmallString.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/Bitcode/BitcodeReader.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/MemoryBuffer.h>


class CxxJIT {
    public:
        
        CxxJIT() {
            llvm::InitializeNativeTarget();
            llvm::InitializeNativeTargetAsmPrinter();
            ctx = std::make_unique<llvm::LLVMContext>();
            jit = cantFail(llvm::orc::LLJITBuilder().create());
            Clang = std::make_unique<clang::CompilerInstance>();
            jit->getMainJITDylib().addGenerator(cantFail(llvm::orc::DynamicLibrarySearchGenerator::GetForCurrentProcess(jit->getDataLayout().getGlobalPrefix())));
            Clang->createDiagnostics();
            
            diagId = new clang::DiagnosticIDs;
            diagOpts = new clang::DiagnosticOptions;
            diagBuf = new clang::TextDiagnosticBuffer;
            diag = new clang::DiagnosticsEngine(diagId, &*diagOpts, diagBuf);
        }
        
        ~CxxJIT() {
            for (auto d : deleters) d();
        }
        
        
        bool compile(std::string src) {
            int fd;
            llvm::SmallString<128> llvmcppf;
            if (auto ec = llvm::sys::fs::createTemporaryFile("cxx-jit", "cpp", fd, llvmcppf)) {
                errors.push_back(ec.message());
                return false;
            }
            llvm::raw_fd_ostream os(fd, true, true);
            os << src;
            std::string cppf = llvmcppf.str().str();
            std::string bcf = cppf.substr(0, cppf.find_last_of('.') + 1) + "bc";
            llvm::SmallVector<const char *, 256> args = {"-emit-llvm","-S","-o", bcf.data(), cppf.data()};
            
            clang::driver::Driver driver("", llvm::sys::getDefaultTargetTriple(), *diag);
                        
            //driver.setInstalledDir(std::filesystem::current_path().string());
                       
            std::unique_ptr<clang::driver::Compilation> compilation(driver.BuildCompilation(args));           
            if (compilation->containsError()) {
                errors.push_back("error: invocation issue");
                return false;
            }
            
            auto &cmd = *compilation->getJobs().begin();
            auto argv = cmd.getArguments();
            argv.emplace_back("-emit-llvm-bc");
            bool success = clang::CompilerInvocation::CreateFromArgs(Clang->getInvocation(), argv, *this->diag);
            if (!success) errors.push_back("Could not invoke compiler");
                      
            Clang->createDiagnostics();
            
            this->diagBuf->FlushDiagnostics(Clang->getDiagnostics());
            if (!success) return false;
            
            success = ExecuteCompilerInvocation(Clang.get());
            this->diagBuf->FlushDiagnostics(Clang->getDiagnostics());
            if (!success || !std::filesystem::exists(bcf)) {
                errors.push_back("compilation error. check stdout.");
                return false;
            }

                       
            llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>> buffer = llvm::MemoryBuffer::getFile(bcf);
            if (!buffer) {
                errors.push_back(buffer.getError().message());
                return false;
            }
            
            auto module = parseBitcodeFile(buffer.get()->getMemBufferRef(), *ctx);
            
            llvm::sys::fs::remove(bcf);
            llvm::sys::fs::remove(cppf);
            
            if (!module) {    
                llvm::Error err = module.takeError();
                llvm::handleAllErrors(std::move(err), [&](const llvm::StringError &strErr) {
                    errors.push_back("error creating module: " + strErr.getMessage());
                });
                return false;
            }
                        
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
               
        std::vector<const char *> driverArgv;
    private:
        std::unique_ptr<llvm::LLVMContext> ctx;
        std::unique_ptr<llvm::orc::LLJIT> jit;
        
        std::vector<std::function<void()>> deleters;
        std::unique_ptr<clang::CompilerInstance> Clang;
        std::vector<std::string> errors;
        clang::IntrusiveRefCntPtr<clang::DiagnosticIDs> diagId;
        clang::IntrusiveRefCntPtr<clang::DiagnosticOptions> diagOpts;
        clang::TextDiagnosticBuffer *diagBuf;
        clang::DiagnosticsEngine *diag;
                
};



