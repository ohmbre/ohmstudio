QT += quickcontrols2 svg qml
CONFIG += c++latest precompile_header qmltypes
LANGUAGE = C++
DEFINES += QT_DEPRECATED_WARNINGS
SOURCES += \
    main.cpp \
    conductor.cpp \
    function.cpp \
    audio.cpp \
    scope.cpp \
    midi.cpp \
    dsp.cpp \
    external/RtMidi.cpp \
    external/tinycc/libtcc.c


HEADERS += \
    conductor.hpp \
    function.hpp \
    audio.hpp \
    scope.hpp \
    pch.hpp \
    dsp.hpp \
    midi.hpp \
    external/exprtk.hpp \
    external/miniaudio.h \
    external/RtMidi.h \



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

QML_IMPORT_NAME = ohm
QML_IMPORT_MAJOR_VERSION = 1

linux,android,mac {
    QMAKE_CLEAN *= -r ohm moc obj rcc ui Makefile .qmake.stash
    QMAKE_CXXFLAGS=-Wno-format-security -Wno-implicit-fallthrough -ftemplate-depth=4096 -Wno-old-style-cast -O2
}

windows {
    QMAKE_CXXFLAGS += /bigobj
}
mac {
    QMAKE_MAC_SDK = macosx10.15
}
android {
  DISTFILES += $$files(droid/*.*, true)
  ANDROID_PACKAGE_SOURCE_DIR = $$PWD/droid
}

TARGET=ohm
OBJECTS_DIR=obj
RCC_DIR=rcc
UI_DIR=ui
MOC_DIR=moc




