
import QtQuick 2.11
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.13


Rectangle {


    id: mOver
    anchors.fill: parent
    visible: module != null
    clip: true
    z: 10
    color: 'black'
    property Module module: null

    OhmButton {
        text: "←"
        font.pixelSize: 35
        padding: 0
        width: 46
        height:46
        radius: 23
        x:10
        y:5
        z:2
        verticalAlignment: Text.AlignTop
        onClicked: {
            mOver.module = null;
        }
    }


    Rectangle {
        color: Style.moduleColor
        width: parent.width * .86
        height: parent.height * .86
        x: parent.width * .07
        y: parent.height * .07
        radius: 15
        border.color: Style.moduleBorderColor
        border.width: 5

        OhmText {
            id: moduleLabel
            width: parent.width
            horizontalAlignment: Item.Center
            text: mOver.module ? mOver.module.label : ''
            color: Style.moduleLabelColor
            font.family: asapSemiBold.name
            font.weight: Font.DemiBold
            font.pixelSize: 10
            maximumLineCount: 2
            elide: Text.ElideNone
            wrapMode: Text.WordWrap
            y: 15
        }

        Item {
            width: parent.width*.8
            height: parent.height*.8
            x: parent.width*.1
            y: parent.height*.1
            Loader {
                id: displayLoader
                anchors.fill: parent
                sourceComponent: mOver.module ? mOver.module.display : null
                active: mOver.module && mOver.module.display
            }
        }

        GridLayout {
            id: controllers
            width: parent.width-parent.border.width*2;
            height: parent.height-parent.border.width*2-30;
            x: parent.border.width; y: parent.border.width+30
            columns: Math.floor(width / maxChildWidth())
            flow: GridLayout.LeftToRight
            rowSpacing: 0
            columnSpacing: 0
            property var cvs: module ? module.cvs : []
            Repeater {
                id: cvRepeater
                model: controllers.cvs
                delegate: Loader {
                    Layout.alignment: Layout.Center
                    sourceComponent: controller
                    active: module != null
                }
            }

            function maxChildWidth() {
                var w = 0
                for (var i = 0; i < children.length; i++)
                    w = Math.max(children[i].width, w)
                return w
            }
        }
    }

    property Module lastModule: null

}
