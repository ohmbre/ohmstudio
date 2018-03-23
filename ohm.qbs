import qbs 1.0
Project {
    Application {
        readonly property stringList qmlImportPaths : [path]
        cpp.cxxLanguageVersion: "c++11"
        cpp.defines: ["QT_DEPRECATED_WARNINGS"]
        files: ["main.cpp", "qml.qrc", "qmldir"]
        Group {
            fileTagsFilter: "application"
            qbs.install: true
            qbs.installRoot: "dist"
        }
        Depends { name: "Qt.core" }
        Depends { name: "Qt.quick" }
        Depends { name: "cpp" }
    }
}
