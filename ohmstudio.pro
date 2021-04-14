QT += quickcontrols2 svg qml shadertools-private 
CONFIG +=  c++latest precompile_header no_keywords
DEFINES += QT_DEPRECATED_WARNINGS
SOURCES += \
    main.cpp \
    conductor.cpp \
    function.cpp \
    audio.cpp \
    model.cpp \
    sink.cpp \
    scope.cpp \
    midi.cpp \
    dsp.cpp \
    external/RtMidi.cpp


HEADERS += \
    conductor.hpp \
    function.hpp \
    audio.hpp \
    model.hpp \
    sink.hpp \
    scope.hpp \
    pch.hpp \
    dsp.hpp \
    midi.hpp \
    external/miniaudio.h \
    external/RtMidi.h \
    external/cxx-jit.h
    

PRECOMPILED_HEADER = pch.hpp

RESOURCES += \
    $$files(app/*.qml, true) \
    $$files(app/*.js, true) \
    $$files(app/*qmldir, true) \
    $$files(app/*.mjs, true) \
    $$files(app/*.png, true) \
    $$files(app/*.svg, true) \
    $$files(app/*.ttf, true) \
    $$files(app/*.html, true) \
   qtquickcontrols2.conf

QMAKE_CXXFLAGS += -fno-rtti
#QMAKE_CXXFLAGS += -Wno-ambiguous-reversed-operator -Wno-deprecated-enum-enum-conversion

LLVM_INSTALL=$$(LLVM_INSTALL)
isEmpty(LLVM_INSTALL): LLVM_INSTALL=$$system(llvm-config --prefix)
isEmpty(LLVM_INSTALL): error(either set environment variable LLVM_INSTALL or put llvm-config in your system path)
message(found llvm install path: $${LLVM_INSTALL})
INCLUDEPATH += $${LLVM_INSTALL}/include
QMAKE_CXXFLAGS += $$system($${LLVM_INSTALL}/bin/llvm-config --cxxflags)
LIBS += $$system($${LLVM_INSTALL}/bin/llvm-config --ldflags) $$system($${LLVM_INSTALL}/bin/llvm-config --libs all)


linux,android,mac {
    LIBS += -lclang -lclang-cpp
}

windows {

    QMAKE_CLEAN += debug\* moc\* obj\* rcc\* release\* .qmake.stash Makefile Makefile.Debug Makefile.Release
    LIBS += -L$${LLVM_INSTALL}/lib -lclangBasic -lclangSerialization -lclangFrontend -lclangFrontendTool -lclangParse version.lib
    LIBS += -lclangCodeGen -lclangAST -lclangLex -lclangSema -lclangDriver -lclangARCMigrate -lclangRewrite -lclangRewriteFrontend
    LIBS += -lclangStaticAnalyzerCore -lclangStaticAnalyzerFrontend -lclangStaticAnalyzerCheckers -lclangAnalysis -lclangEdit 
    LIBS += -lclangASTMatchers -lclangCrossTU -lclangIndex -lclangToolingCore
}

mac {
    QMAKE_MAC_SDK = macosx10.15
}

android {
  DISTFILES += $$files(droid/*.*, true)
  ANDROID_PACKAGE_SOURCE_DIR = $$PWD/droid
}

TARGET=ohm


DISTFILES += \
    CMakeLists.txt \
    app/OhmEditor.qml \
    app/RandomWalkModule.qml \
    app/ShaderModule.qml \
    app/TestModule.qml




