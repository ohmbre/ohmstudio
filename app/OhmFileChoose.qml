import QtQuick
import QtQuick.Controls

Item {

    id: fileChooseDialog
    property string directory
    property string extension
    property bool forLoading: false
    property bool forSaving: false
    property bool open
    signal fileChosen(string fileURL)
    width: xpct(50)

    OhmText {
    text: "Choose a File"
    color: 'black'
        font.pixelSize: 7
    x: xpct(4)
    y: ypct(4)
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignLeft
    }

    Rectangle {
    x: xpct(5)
    y: ypct(10)
    width: xpct(40)
    height: ypct(82)
    color: 'white'
    clip: true
    border.color: 'black'
    border.width: 1

    property string saveFile: fileChoose.folder + '/' + fileChoose.footerItem.text
    ListView {
            id: fileChoose
            anchors.fill: parent
            anchors.margins: 1
        headerPositioning: ListView.OverlayHeader
            footerPositioning: ListView.OverlayFooter
            keyNavigationEnabled: fileChooseDialog.open
            property bool open: fileChooseDialog.open
            onOpenChanged: {
        folder = fileChooseDialog.directory
        model = maestro.listDir(folder,match,directory)
            }
            focus: fileChooseDialog.open
            property string folder: fileChooseDialog.directory
            property string ext: '*.'+fileChooseDialog.extension
            property string match: '*'+ext
            model: maestro.listDir(folder,match,directory)
            delegate: OhmText {
        property string path: modelData
        property var parts: path.split('/')
        property string leaf: parts[parts.length-1]
        property bool isDir: leaf == '..' || leaf.indexOf('.') == -1
        property string stem: parts.slice(0,-1).join('/')
        font.pixelSize: 7
        text: leaf
        color: 'black'
        width: parent.width
        horizontalAlignment: Text.AlignLeft
        leftPadding: 10
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
                            fileChoose.model = maestro.listDir(fileChoose.folder,fileChoose.match,fileChoose.directory)
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
        color: 'white'
        z: 2
        clip: true
        height: xpct(4)
        width: fileChoose.width
        OhmText {
            text: fileChooseDialog.directory + '/'
            font.pixelSize: 7
            font.weight: Font.Bold
            color: 'black'
            padding: 4
        }
        }
            footer: forSaving ? saveBox : emptyFooter
            property Component emptyFooter: Item {}

            property Component saveBox: Rectangle {
        clip: true
        z:2
        width: parent.width
        height: ypct(8)
        Rectangle {
            border.width: 1
            border.color: 'black'
            width: xpct(29)
            height: ypct(5)
            x: xpct(1)
            TextInput {
            id: saveFileName
            font.pixelSize: 7
            padding: 2
            text: (new Date()).toLocaleString(Qt.locale(),'MMMd-h.map').toLowerCase() + '.qml'
            }
        }
        OhmButton {
            x: xpct(31)
            text: 'save'
            border: 1
            font.pixelSize: 7
            width: xpct(8)
            padding: .5
            onClicked: {
            fileChooseDialog.fileChosen(fileChoose.folder+'/'+saveFileName.text);
            }
        }
        }
    }
    }
}
