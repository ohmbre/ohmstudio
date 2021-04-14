cmake_minimum_required(VERSION 3.16.0)
project(ohmstudio VERSION 0.5.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CXX_EXTENSIONS OFF)
add_compile_options(
    "$<$<CXX_COMPILER_ID:MSVC>:-wd4624;-wd4141;-wd4834;-wd4267;-wd4015;-wd4291>"
    "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fno-rtti>"
    "$<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:DEBUG>>:-fno-omit-frame-pointer>"
)



if (MSVC)
    add_definitions(-D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS -D__WINDOWS_MM__)
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

file(GLOB_RECURSE resource_files RELATIVE ${CMAKE_SOURCE_DIR} 
    app/*.qml app/*.mjs app/*.png app/*.svg app/*.ttf)

find_package(Qt6 COMPONENTS Quick QuickControls2 Svg Qml ShaderTools REQUIRED)
find_package(LLVM REQUIRED CONFIG HINTS ${LLVM_DIR})
find_package(Clang REQUIRED)

include_directories(${CMAKE_SOURCE_DIR} ${LLVM_INCLUDE_DIRS} ${CLANG_INCLUDE_DIRS})
include_directories(${Qt6ShaderTools_PRIVATE_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})
add_definitions(${LLVM_DEFINITIONS})

add_executable(ohm
    main.cpp
    conductor.cpp
    func.cpp
    audio.cpp
    sink.cpp
    midi.cpp
    external/RtMidi.cpp
)

llvm_map_components_to_libnames(llvm_libnames core orcjit native support)
target_link_libraries(ohm PRIVATE ${llvm_libnames} clangAST clangBasic clangLex clangCodeGen clangFrontendTool
    clangFrontend clangEdit clangSerialization clangSema clangDriver clangParse clangAnalysis)
target_link_libraries(ohm PRIVATE Qt6::Core Qt6::Gui Qt6::Svg Qt6::Qml Qt6::Quick Qt6::ShaderTools)
if (MSVC)
    target_link_libraries(ohm PRIVATE winmm)
endif()


execute_process(COMMAND ${CMAKE_COMMAND} -E touch tmp.cpp)
execute_process(COMMAND ${LLVM_TOOLS_BINARY_DIR}/clang -v -std=c++17 -S -emit-llvm -o tmp.bc tmp.cpp
    ERROR_VARIABLE clang_info
    OUTPUT_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)

set(cc1args "")
string(REGEX REPLACE "\r?\n" ";" lines "${clang_info}")
foreach(line ${lines})
    string(REGEX MATCH "-emit-llvm" match "${line}")
    if (match)
        string(REGEX REPLACE " -" ";-" args "${line}")
        list(POP_FRONT args) 
        foreach(arg ${args})
            string(REGEX REPLACE " " ";" toks "${arg}")
            list(GET toks 0 headtok)
            set(skipflags "-v;-cc1;-main-file-name;-fdebug-compilation-dir;-o;-fmath-errno")
            if(NOT headtok IN_LIST skipflags)
                string(REGEX REPLACE "[ ]?tmp.cpp[ ]?" "" arg "${arg}")
                list(APPEND cc1args "${arg}")
            endif()
        endforeach()
    endif()
endforeach()
list(JOIN cc1args " " cc1args)
target_compile_definitions(ohm PRIVATE "CXXJIT_ARGS=${cc1args}")

set_target_properties(ohm PROPERTIES
    QT_QML_MODULE_VERSION 1.0
    QT_QML_MODULE_URI     ohm
)
qt_qml_type_registration(ohm)

qt_add_resources(ohm "ohm" PREFIX "/" FILES ${resource_files})


#get_cmake_property(_variableNames VARIABLES)
#list (SORT _variableNames)
#foreach (_variableName ${_variableNames})
#    message(STATUS "${_variableName}=${${_variableName}}")
#endforeach()
