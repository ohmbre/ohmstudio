
import QtQuick 2.12
import QtQuick.Controls 2.4

Item {
    id: mView
    x: centerInX(this, this.parent) + module.x
    y: centerInY(this, this.parent) + module.y
    z: 1
    width: 48; height: 32
    property Module module;
    property alias outline: outline

    OhmRect {
        id: outline
        x:-1; y:-1; z: 0
        wb: parent.width+2
        hb: parent.height+2
        radius: height/2
        color: "white"
        border: 3
        borderColor: 'black'
        onPressAndHold: pView.contentItem.confirmDeleteModule(module)
        onClicked: {
            var anyExtended = false
            for (var j = 0; j < module.nJacks; j++)
                if (module.jack(j).view.extension > 0) {
                    anyExtended = true
                    break
                }

            if (anyExtended) collapseAll()
            else extendAll()
        }
        onDoubleClicked: pView.moduleOverlay.module = module
        dragTarget: parent
    }

    function collapseAll() {
        for (var j = 0; j < module.nJacks; j++)
            module.jack(j).view.collapse()
    }

    function extendAll() {
        for (var j = 0; j < module.nJacks; j++)
            module.jack(j).view.extend()
    }

    OhmText {
        id: moduleLabel
        text: module.label
        padding: 5
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        color: 'black'
        font.family: asapSemiBold.name
        font.weight: Font.DemiBold
        font.pixelSize: 10
        minimumPixelSize: 8
        maximumLineCount: 2
        elide: Text.ElideNone
        wrapMode: Text.WordWrap
    }

    Rectangle {
        id: perimeter
        width: parent.width + 20
        height: parent.height + 20
        x: -10
        y: -10
        visible: false
    }
    property alias perimeter: perimeter

    property double cstart: mView.width/2 - mView.height/2
    property double tstart: cstart + Math.PI * mView.height / 2
    property double perim: tstart + mView.width/2 - mView.height/2


    function computeJackPos(jacks) {
        var sweep = perim / jacks.length
        var shapeData = {}
        for (var j = 0, start = 0; j < jacks.length; j++, start += sweep) {
            var center = start + sweep/2
            var sdelta = (j === 0) ? (sweep/2) : (sweep/2-0.35)
            var edelta = (j === jacks.length-1) ? (sweep/2) : (sweep/2-0.35)
            shapeData[jacks[jacks.length-j-1]] = {
                start: center - Math.min(sdelta, 10),
                center: center,
                end: center + Math.min(edelta, 10),
                theta: global.clip(-Math.PI/2,
                                   2*(center-cstart)/mView.height - Math.PI/2,
                                   Math.PI/2)
            }
        }
        return shapeData
    }


    Repeater {
        anchors.fill: parent
        model: module.inJacks
        InJackView {
            jack: modelData
            shapeData: computeJackPos(module.inJacks)[modelData]
            posRef: Qt.point(mView.height/2, mView.height/2)
        }
    }

    Repeater {
        anchors.fill: parent
        model: module.outJacks
        OutJackView {
            jack: modelData
            shapeData: computeJackPos(module.outJacks)[modelData]
            posRef: Qt.point(mView.width - mView.height/2, mView.height/2)
        }
    }

    Component.onCompleted: {
        module.view = mView;
        module.x = Qt.binding(function() { return mView.x - centerInX(mView, mView.parent);});
        module.y = Qt.binding(function() { return mView.y - centerInY(mView, mView.parent);});
    }

}
