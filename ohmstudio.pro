QT += quickcontrols2 svg multimedia qml
CONFIG += c++latest precompile_header
LANGUAGE = C++
DEFINES += QT_DEPRECATED_WARNINGS
SOURCES += \
    main.cpp \
    conductor.cpp \
    function.cpp \
    sink.cpp \
    audio.cpp \
    scope.cpp \
    fileio.cpp \
    midi.cpp \
    external/RtMidi.cpp


HEADERS += \
    conductor.hpp \
    function.hpp \
    sink.hpp \
    audio.hpp \
    scope.hpp \
    fileio.hpp \
    pch.hpp \
    midi.hpp

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


QMAKE_CLEAN *= -r ohm moc obj rcc ui Makefile .qmake.stash

linux {
    QMAKE_CXXFLAGS=-Wno-format-security -Wno-implicit-fallthrough -ftemplate-depth=4096 -Wno-old-stype-cast
    QMAKE_CXXFLAGS += -D__LINUX_ALSA__
    QMAKE_LFLAGS += -lasound
}


QML_IMPORT_PATH += ohmstudio ohmstudio/app app

QMAKE_MAC_SDK = macosx10.14

android {
  DISTFILES += $$files(droid/*.*, true)
  ANDROID_PACKAGE_SOURCE_DIR = $$PWD/droid
}

TARGET=ohm
OBJECTS_DIR=obj
RCC_DIR=rcc
UI_DIR=ui
MOC_DIR=moc


