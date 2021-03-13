import QtQuick
import QtQuick.Shapes

Shape {
    id: cView
    property var cable

    ShapePath {
        id: cPath
        strokeWidth: 2.5
        strokeColor: '#F55D3E'
        fillColor: "transparent"
        property var ok: {
            let ret = cable && cable.out && cable.inp && cable.out.view && cable.inp.view;
            console.log('ok:',ret);
            return ret;
        }
        startX: ok ? cable.out.view.anchor1X : 0
        startY: ok ? cable.out.view.anchor1Y : 0

        PathCubic {
            property alias ok: cPath.ok
            control1X: ok ? cable.out.view.anchor3X : 0
            control1Y: ok ? cable.out.view.anchor3Y : 0
            control2X: ok ? cable.inp.view.anchor3X : 0
            control2Y: ok ? cable.inp.view.anchor3Y : 0
            x: ok ? cable.inp.view.anchor1X : 0
            y: ok ? cable.inp.view.anchor1Y : 0
        }
    }

    Component.onCompleted: {
        cable.view = this;
    }
}

