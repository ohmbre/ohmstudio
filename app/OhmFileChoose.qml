import QtQuick 2.13
import QtQuick.Controls 2.13

Rectangle {
    id: fileChooseDialog
    width: 200
    height: globalHeight*0.8
    color: 'white'
    clip: true
    property string directory
    property string extension
    property bool forLoading: false
    property bool forSaving: false
    property bool open

    signal fileChosen(string fileURL)

    property string saveFile: fileChoose.folder + '/' + fileChoose.footerItem.text
    ListView {
        id: fileChoose
        anchors.fill: parent
        anchors.margins: 15
        footerPositioning: ListView.OverlayFooter
        keyNavigationEnabled: fileChooseDialog.open
        property bool open: fileChooseDialog.open
        onOpenChanged: {
            folder = fileChooseDialog.directory
            model = FileIO.listDir(folder,match,directory)
        }
        focus: fileChooseDialog.open
        property string folder: fileChooseDialog.directory
        property string ext: '*.'+fileChooseDialog.extension
        property string match: '*'+ext
        model: FileIO.listDir(folder,match,directory)
        delegate: OhmText {
            leftPadding: 5
            rightPadding: 5
            topPadding: 2
            bottomPadding: 2
            property string path: modelData
            property var parts: path.split('/')
            property string leaf: parts[parts.length-1]
            property bool isDir: leaf == '..' || leaf.indexOf('.') == -1
            property string stem: parts.slice(0,-1).join('/')
            text: leaf
            color: 'black'
            width: parent.width
            height: 13
            horizontalAlignment: Text.AlignLeft
            Image {
                source: 'qrc:/app/ui/icons/arrow.svg'
                visible: isDir
                width: 11
                height: 5
                horizontalAlignment: Image.AlignRight
                y: 4.5
                x: parent.width - width - 4
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (isDir) {
                        if (leaf == '..')
                            fileChoose.folder = parts.slice(0,-2).join('/')
                        else fileChoose.folder = path
                        fileChoose.model = FileIO.listDir(fileChoose.folder,fileChoose.match,fileChoose.directory)
                    } else {
                        if (fileChooseDialog.forLoading)
                            fileChooseDialog.fileChosen(path)
                        else if (fileChooseDialog.forSaving)
                            fileChoose.footerItem.text = leaf
                    }
                }
            }
        }
        header: Rectangle {
            width: parent.width
            height:17
            OhmText {
                text: "Patch File"
                color: 'black'
                font.pixelSize: 10
                font.weight: Font.Bold
                padding: 2
                leftPadding: 4
                horizontalAlignment: Text.AlignLeft
            }
            color: 'white'
        }
        footer: forSaving ? saveBox : emptyFooter
        property Component emptyFooter: Item {}

        property Component saveBox: TextField {
            clip: true
            z:2
            placeholderText: qsTr("Enter filename")
            font.family: asapMedium.name
            font.pixelSize: 11
            height: 20
            width: fileChooseDialog.width
            padding: 1
            text: (new Date()).toLocaleString(Qt.locale(),'MMMd-h.map').toLowerCase() + '.qml'
        }
    }
}
