import qbs


Project {
    Product {


        property pathList qmlImportPaths: ['.','ohm']

        Group {
            name: "c++"
            files: ["main.cpp"]
        }

        Group {
            name: "qml"
            prefix: "ohm/**/"
            files: ['*.qml', '*qmldir', '*.ttf', '*.js', '*.svg']
            excludeFiles: ["*.qmlc"]
            //fileTags: ["qt.core.resource_data"]
            //Qt.core.resourceSourceBase: "ohm"
            //Qt.core.resourcePrefix: "/ohm"
            qbs.install: true
            qbs.installDir: "ohm"
            qbs.installSourceBase: "ohm"
        }

        Group {
            name: "distributed examples"
            prefix: "examples/"
            files: ["*.qml"]
            qbs.install: true
            qbs.installDir: "patches/examples"
            qbs.installSourceBase: "patches/examples"
        }

        Group {
            name: "python"
            files: ["main.py","ohmrun","config.env"]
            qbs.install: true
        }

        Group {
            fileTagsFilter: ["application", "aggregate_infoplist", "pkginfo"]
            qbs.install: true
            qbs.installSourceBase: product.buildDirectory
        }
    }
}
