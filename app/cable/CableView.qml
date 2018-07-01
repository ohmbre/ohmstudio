import QtQuick 2.11
import QtQuick.Shapes 1.11

import ohm 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.helpers 1.0
import ohm.ui 1.0

Shape {
    id: cView
    property Cable cable
	    
    ShapePath {
        id: cPath
        strokeWidth: 2.5
        strokeColor: Style.cableColor
        fillColor: "transparent"
	startX: cable.out.view.anchor1X
	startY: cable.out.view.anchor1Y
	PathCubic {
	    control1X: cable.out.view.anchor3X
	    control1Y: cable.out.view.anchor3Y
	    control2X: cable.inp.view.anchor3X
	    control2Y: cable.inp.view.anchor3Y
	    x: cable.inp.view.anchor1X
	    y: cable.inp.view.anchor1Y
	}
    }

    Component.onCompleted: {
        cable.view = cView;
    }
}

