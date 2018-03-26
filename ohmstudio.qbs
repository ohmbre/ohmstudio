import qbs

Product {
    type: ["application"]
    Depends {
        name: "Qt"
        submodules: ["core", "gui", "qml"]
    }
    Depends { name: "cpp" }
    cpp.defines: ["QT_QML_DEBUG"]

    // Depends { name: "cpp" }
    files: [
        "main.cpp",
        "qml.qrc",
        "qmldir",
    ]
}
