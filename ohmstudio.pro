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

QMAKE_CFLAGS=-O2
QMAKE_CXXFLAGS=-Wno-format-security -Wno-implicit-fallthrough -ftemplate-depth=4096 -O2
linux {
    QMAKE_CXXFLAGS += -D__LINUX_ALSA__
    QMAKE_LFLAGS += -lasound
}


QML_IMPORT_PATH += ohmstudio ohmstudio/app app

QMAKE_MAC_SDK = macosx10.14

android {
  DISTFILES += \
    droid/AndroidManifest.xml \
    droid/gradle/wrapper/gradle-wrapper.jar \
    droid/gradlew \
    droid/res/values/libs.xml \
    droid/build.gradle \
    droid/gradle/wrapper/gradle-wrapper.properties \
    droid/gradlew.bat \
    droid/res/drawable/ic_launcher.xml \
    droid/res/mipmap-anydpi/ic_foreground.xml \
    droid/res/color/ic_background.xml \
    droid/res/drawable/ic_launcher_foreground.xml \
    droid/res/mipmap-anydpi-v26/ic_launcher.xml \
    droid/res/mipmap-anydpi-v26/ic_launcher_round.xml \
    droid/res/values/ic_launcher_background.xml \
    droid/res/mipmap-hdpi/ic_launcher.png \
    droid/res/mipmap-hdpi/ic_launcher_round.png \
    droid/res/mipmap-mdpi/ic_launcher.png \
    droid/res/mipmap-mdpi/ic_launcher_round.png \
    droid/res/mipmap-xhdpi/ic_launcher.png \
    droid/res/mipmap-xhdpi/ic_launcher_round.png \
    droid/res/mipmap-xxhdpi/ic_launcher.png \
    droid/res/mipmap-xxhdpi/ic_launcher_round.png \
    droid/res/mipmap-xxxhdpi/ic_launcher.png \
    droid/res/mipmap-xxxhdpi/ic_launcher_round.png
  ANDROID_PACKAGE_SOURCE_DIR = $$PWD/droid
}

TARGET=ohm
OBJECTS_DIR=obj
RCC_DIR=rcc
UI_DIR=ui
MOC_DIR=moc


