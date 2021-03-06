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
    dsp.cpp \
    external/RtMidi.cpp


HEADERS += \
    conductor.hpp \
    function.hpp \
    sink.hpp \
    audio.hpp \
    scope.hpp \
    fileio.hpp \
    pch.hpp \
    dsp.hpp \
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



