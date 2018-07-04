import QtQuick 2.11
import QtQuick.Controls 2.4

Rectangle {
    id: fileChooseDialog
    visible: false
    opacity: 0
    width: setup.width*0.65/scale;
    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
    height: window.height*0.8/scale;
    color: Style.fileChooseBgColor
    x:15
    y: header.height+13
    transformOrigin: Item.TopLeft
    property real contentScale: 1
    property string directory
    property string extension
    property bool forLoading: false
    property bool forSaving: false
    signal fileChosen(string fileURL)
    function open() {
        fileChooseDialog.visible = true;
        fileChooseDialog.opacity = 1.0;
    }
    function close() {
        fileChooseDialog.visible = false;
        fileChooseDialog.opacity = 0;
    }

    property string saveFile: fileChoose.folder + '/' + fileChoose.footerItem.text
    ListView {
        id: fileChoose
        anchors.fill: parent
        footerPositioning: ListView.OverlayFooter
        keyNavigationEnabled: true
        highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
        focus: fileChooseDialog.visible
	property string folder: fileChooseDialog.directory
        model: FileIO.listDir(folder,"*."+fileChooseDialog.extension)
        delegate: OhmText {
            leftPadding: 5
            rightPadding: 5
            topPadding: 2
            bottomPadding: 2
	    property var parts: modelData.split('/')
	    property string leaf: parts[parts.length-1]
	    property bool isDir: leaf.slice(-4) != ('.'+fileChooseDialog.extension)
	    property string stem: parts.slice(0,-1).join('/')
            text: leaf
            color: Style.fileChooseTextColor
            width: parent.width
            height: 13
            horizontalAlignment: Text.AlignLeft
	    Image {
		source: 'ui/icons/arrow.svg'
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
                        else fileChoose.folder = modelData
                    } else {
                        if (fileChooseDialog.forLoading)
                            fileChooseDialog.fileChosen(modelData)
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
        footer: forSaving ? saveBox: emptyFooter
        property Component emptyFooter: Item {}
        property Component saveBox: TextField {

            placeholderText: qsTr("Enter filename")
            font.family: asapFont.name
            font.pixelSize: 11
            height: 20
            width: fileChooseDialog.width
            padding: 1
            text: (new Date()).toLocaleString(Qt.locale(),'MMMd-h.map').toLowerCase() + '.qml'
        }
    }
}
