import QtQuick 2.11
import QtQuick.Controls 2.4

Rectangle {
    id: fileChooseDialog
    opacity: open ? 1 : 0
    visible: opacity > 0
    width: setup.width*0.65/scale;
    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
    height: window.height*0.8/scale;
    color: Style.fileChooseBgColor
    x:15
    y: header.height+13
    transformOrigin: Item.TopLeft
    clip: true
    property real contentScale: 1
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
        footerPositioning: ListView.OverlayFooter
        keyNavigationEnabled: fileChooseDialog.open
        highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
        property bool open: fileChooseDialog.open
        onOpenChanged: {
            folder = fileChooseDialog.directory
            model = HWIO.listDir(folder,match)
        }
        focus: fileChooseDialog.open
        property string folder: fileChooseDialog.directory
        property string ext: '*.'+fileChooseDialog.extension
        property string match: '*'+ext
        model: HWIO.listDir(folder,match)
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
            color: Style.fileChooseTextColor
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
                enabled: open
                anchors.fill: parent
                onClicked: {
                    if (isDir) {
                        if (leaf == '..')
                            fileChoose.folder = parts.slice(0,-2).join('/')
                        else fileChoose.folder = path
                        fileChoose.model = HWIO.listDir(fileChoose.folder,fileChoose.match)
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
                color: Style.fileChooseTextColor
                font.pixelSize: 11
                font.weight: Font.Bold
                padding: 2
                leftPadding: 4
                horizontalAlignment: Text.AlignLeft
            }
            color: Style.buttonBorderColor
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
