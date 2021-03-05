
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Rectangle {


    id: mOver
    anchors.fill: parent
    visible: module != null
    clip: true
    z: 10
    color: 'white'
    property Module module: null

    OhmButton {
        text: "←"
        font.pixelSize: 39
        x:0; y: 0; z:2; width: 50; height:50; radius: 25; padding: 0; border: 4
        verticalAlignment: Text.AlignTop
        onClicked: {
            mOver.module = null;
        }
    }


    Rectangle {
        color: 'white'
        width: parent.width * .94
        height: parent.height * .94
        x: parent.width * .03
        y: parent.height * .03
        radius: 15
        border.color: 'black'
        border.width: 5

        OhmText {
            id: moduleLabel
            width: parent.width
            horizontalAlignment: Item.Center
            text: mOver.module ? mOver.module.label : ''
            color: 'black'
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
            height: parent.height*.5
            x: parent.width*.1
            y: parent.height*.19
            Loader {
                id: displayLoader
                width: Math.round(parent.width)
                height: Math.round(parent.height)
                sourceComponent: mOver.module ? mOver.module.display : null
                active: mOver.module && mOver.module.display
            }
        }

        GridLayout {
            id: controllers
            width: parent.width-parent.border.width*2
            height:  (module && module.display) ? (parent.height*0.3) : (parent.height-parent.border.width*2-40)
            x: parent.border.width
            y: (module && module.display) ? (parent.height*0.7) : (parent.border.width+20)
            columns: 8
            rows: 8
            flow: GridLayout.TopToBottom
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
        }
    }

    property Module lastModule: null

}


