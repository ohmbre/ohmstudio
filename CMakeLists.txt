cmake_minimum_required(VERSION 3.16.0)
project(ohmstudio VERSION 0.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CXX_EXTENSIONS OFF)
add_compile_options(
  "$<$<CXX_COMPILER_ID:MSVC>:-wd4624;-wd4141;-wd4834;-wd4267;-wd4015;-wd4291>"
  "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fno-rtti>"
  "$<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:DEBUG>>:-fno-omit-frame-pointer>")

if (MSVC)
  add_definitions(-D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS -D__WINDOWS_MM__)
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

file(GLOB_RECURSE resource_files RELATIVE ${CMAKE_SOURCE_DIR} 
  app/*.qml app/*.mjs app/*.png app/*.svg app/*.ttf app/*.json)

find_package(Qt6 COMPONENTS Quick QuickControls2 Svg Qml ShaderTools REQUIRED)
find_package(Git REQUIRED)

set(arch ${CMAKE_HOST_SYSTEM_PROCESSOR})
if(${arch} MATCHES "Aarch64|aarch64|AARCH64|AArch64|ARM64|Arm64|arm64")
    set(arch "AArch64")
elseif (${arch} MATCHES "Arm|arm|ARM") 
    set(arch "ARM")
elseif (${arch} MATCHES "x86|X86|AMD64|amd64")
    set(arch "X86")
endif()

include(ExternalProject)
set(LLVM_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/llvm)
externalproject_add(llvm
  GIT_REPOSITORY https://github.com/llvm/llvm-project.git
  GIT_TAG llvmorg-12.0.0
  GIT_SHALLOW 1
  SOURCE_SUBDIR llvm
  CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX:PATH=${LLVM_PREFIX}
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -DLLVM_TARGETS_TO_BUILD:STRING=${arch}
  -DLLVM_BUILD_TOOLS:BOOL=OFF
  -DLLVM_BUILD_UTILS:BOOL=OFF
  -DCLANG_BUILD_TOOLS:BOOL=OFF
  -DCMAKE_CXX_STANDARD=17
  -DCMAKE_CXX_FLAGS:String="${CMAKE_CXX_FLAGS}"
  -DLLVM_ENABLE_PROJECTS=clang)

include_directories(${LLVM_PREFIX}/include)
link_directories(${LLVM_PREFIX}/lib)


set(LIBGIT2_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/libgit2)
externalproject_add(libgit2
  GIT_REPOSITORY https://github.com/libgit2/libgit2
  GIT_TAG v1.1.0
  CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX:PATH=${LIBGIT2_PREFIX}
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -DBUILD_SHARED_LIBS=OFF
  -DBUILD_CLAR=OFF
  -DTHREADSAFE=ON)
include_directories(${LIBGIT2_PREFIX}/include)
link_directories(${LIBGIT2_PREFIX}/lib)

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${Qt6ShaderTools_PRIVATE_INCLUDE_DIRS})

add_executable(ohm
    main.cpp
    conductor.cpp
    func.cpp
    audio.cpp
    sink.cpp
    midi.cpp
    model.h
    external/RtMidi.cpp
)

add_dependencies(ohm libgit2 llvm)

target_link_libraries(ohm PRIVATE Qt6::Core Qt6::Gui Qt6::Svg Qt6::Qml Qt6::Quick Qt6::ShaderTools)
if (MSVC)
    target_link_libraries(ohm PRIVATE winmm winhttp rpcrt4 crypt32 version)
endif()

find_package(LLVM REQUIRED CONFIG HINTS ${LLVM_PREFIX})
llvm_map_components_to_libnames(llvm_libnames core orcjit native support option lto coverage)


target_link_libraries(ohm PRIVATE ${llvm_libnames}
  clangAST clangBasic clangLex clangCodeGen clangFrontendTool clangFrontend clangEdit clangRewrite 
  clangRewriteFrontend clangSerialization clangStaticAnalyzerFrontend clangSema clangDriver 
  clangParse clangAnalysis clangArcMigrate clangASTMatchers clangAnalysis clangStaticAnalyzerCore
  clangStaticAnalyzerCheckers clangCrossTU clangToolingCore clangIndex)

target_link_libraries(ohm PRIVATE git2)

target_compile_definitions(ohm PRIVATE "CXXJIT_ARGS=")

set_target_properties(ohm PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI     ohm
)
qt_qml_type_registration(ohm)

qt_add_resources(ohm "ohm" PREFIX "/" FILES ${resource_files})


get_cmake_property(_variableNames VARIABLES)
list (SORT _variableNames)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
