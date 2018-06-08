import QtQuick 2.10
import QtQuick.Controls 2.2
import Qt.labs.folderlistmodel 2.11


Rectangle {
    id: fileChooseDialog
    visible: false
    opacity: 0
    width: setup.width*0.65;
    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad }}
    height: window.height*0.8;
    color: Style.fileChooseBgColor
    x:15
    y: header.height+13
    
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

    property string saveFile: fileChoose.model.folder + '/' + fileChoose.footerItem.text
    ListView {
        id: fileChoose
        anchors.fill: parent
	footerPositioning: ListView.OverlayFooter
        keyNavigationEnabled: true
        highlight: Rectangle { color: Style.fileChooseLitColor; radius: 7 }
        focus: fileChooseDialog.visible
        model: FolderListModel {
            id: fileChooseModel
            folder: '../../patches'
            rootFolder: '../../patches'
            nameFilters: ["*.qml",".."]
            showDirs: true
            showDirsFirst: true
            showHidden: false
            showDotAndDotDot: true
	    showOnlyReadable: true
            showFiles: true
        }
        delegate: OhmText {
            leftPadding: 5
            rightPadding:5
            topPadding: 2
            bottomPadding: 2
            text: fileName == '.' ? '' : fileName
            color: Style.fileChooseTextColor
            width: parent.width
	    height: fileName == '.' ? 0 : 13
            horizontalAlignment: Text.AlignLeft
            MouseArea {
                anchors.fill: parent
                onClicked: {
		    fileChoose.currentIndex = index
                    if (fileIsDir) {
                        if (fileName == '..') fileChooseModel.folder = fileChooseModel.parentFolder;
                        else fileChooseModel.folder += '/' + fileName;
                    } else {
			if (fileChooseDialog.forLoading)
			    fileChooseDialog.fileChosen(fileURL)
			else if (fileChooseDialog.forSaving)
			    fileChoose.footerItem.text = fileName
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
            OhmText {
                width: parent.width
                text: "Saved"
                color: Style.fileChooseTextColor
                font.weight: Font.Bold
                padding: 2
                rightPadding: 4
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
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
