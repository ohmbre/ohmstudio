import qbs 1.0
Project {
    Application {
        cpp.cxxLanguageVersion: "c++11"
        cpp.defines: ["QT_DEPRECATED_WARNINGS"]
        files: ["main.cpp", "qml.qrc", "qrc.py"]
        Group {
            fileTagsFilter: "application"
            qbs.install: true
            qbs.installDir: "dist"
        }
        Depends { name: "Qt.core" }
        Depends { name: "Qt.quick" }
        Depends { name: "cpp" }
    }
}
