QT += quickcontrols2 svg multimedia qml
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += main.cpp

RESOURCES += $$files(app/*.qml, true) \
             $$files(app/*.js, true) \
             $$files(app/*qmldir, true) \
             $$files(app/*.mjs, true) \
             $$files(app/*.png, true) \
             $$files(app/*.svg, true) \
             $$files(app/*.ttf, true)

QML_IMPORT_PATH =
QML_DESIGNER_IMPORT_PATH =
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


