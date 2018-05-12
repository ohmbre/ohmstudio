import QtQuick 2.10
import QtQuick.Shapes 1.11

import ohm 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

Shape {
    property Cable cable
    property OutJackView ojv: cable.out.view
    property ModuleView ojm: ojv ? ojv.parent : null
    property InJackView ijv: cable.inp.view
    property ModuleView ijm: ijv ? ijv.parent : null

    width: pView.width;
    height: pView.height;
    antialiasing: true
    layer.samples: 8

    ShapePath {
        id: cableView
        strokeWidth: 2.5
        strokeColor: Style.cableColor
        fillColor: "transparent"
        joinStyle: ShapePath.RoundJoin
        strokeStyle: ShapePath.SolidLine
        startX: Fn.centerX(ojm)
        startY: Fn.centerY(ojm)

        PathCubic {
            id: pathCubic
            property double c: Style.cableControlStiffness
            x: Fn.centerX(ijm)
            y: Fn.centerY(ijm)
            control1X:
            c * ojv.r*Math.cos(ojv.theta) + Fn.centerX(ojm)
            control1Y:
            -c * ojv.r*Math.sin(ojv.theta) + Fn.centerY(ojm)
            control2X:
            c * ijv.r*Math.cos(ijv.theta) + Fn.centerX(ijm)
            control2Y:
            -c * ijv.r*Math.sin(ijv.theta) + Fn.centerY(ijm)

        }
    }

    Component.onCompleted: {
        cable.view = cableView;
    }
}

