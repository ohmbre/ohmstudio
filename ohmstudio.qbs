import qbs

CppApplication {
    type: ["application"]
    Depends {
        name: "Qt"
        submodules: ["core", "gui", "qml"]
    }
    cpp.defines: ["QT_QML_DEBUG"]

    files: [
        "main.cpp",
        "qml.qrc",
        "qmldir",
    ]

    Group {
        fileTagsFilter: "application"
        qbs.install: true
    }
}

