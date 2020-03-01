import QtQuick 2.12
import QtQuick.Shapes 1.11

Shape {
    id: cView
    property Cable cable

    ShapePath {
        id: cPath
        strokeWidth: 2.5
        strokeColor: '#F55D3E'
        fillColor: "transparent"
        property var ok: cable && cable.out && cable.inp && cable.out.view && cable.inp.view
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
        cable.view = cView;
    }
}

