import QtQuick 2.14
import QtQuick.Shapes 1.11


Module {
    id: waveMod
    label: 'Spectral VCO'
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV { label: 'ctrlGain'; volts: 3 }

    Variable { label: 'xphase'; value: [0,0,0,0,0,0,0,0,0,0,0,0,0,0] }
    Variable { label: 'phase' }

    OutJack {
        label: 'waveForm'
        expression:
            'var freq := 220Hz * 2^(ctrlFreq+inFreq);
             xphase[0] += freq / 3;
             xphase[1] += freq / 2;
             xphase += freq;
             xphase[2] += freq * 2;
             xphase[3] += freq * 3;
             xphase[4] += freq * 4;
             xphase[5] += freq * 5;
             xphase[6] += freq * 6;
             xphase[7] += freq * 7;
             xphase[8] += freq * 8;
             xphase[9] += freq * 9;
             xphase[10] += freq * 10;
             xphase[11] += freq * 11;
             xphase[12] += freq * 12;
             xphase[13] += freq * 13;
             (inGain + ctrlGain) * (a[0]*cos(xphase[0]) + a[1]*cos(xphase[1]) + cos(phase) + a[2]*cos(xphase[2]) + a[3]*cos(xphase[3]) + a[4]*cos(xphase[4]) + a[5]*cos(xphase[5]) + a[6]*cos(xphase[6]) + a[7]*cos(xphase[7]) + a[8]*cos(xphase[8]) + a[9]*cos(xphase[9]) + a[10]*cos(xphase[10]) + a[11]*cos(xphase[11]) + a[12]*cos(xphase[12]) + a[13]*cos(xphase[13]))'
    }

    Variable {
        label: 'a'
        value: [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    }
    property var evenPoints: [{x:-1,y:variable('a').value[1]}, {x:1,y:variable('a').value[2]}, {x:3,y:variable('a').value[4]}, {x:5,y:variable('a').value[6]}, {x:7,y:variable('a').value[8]}, {x:9,y:variable('a').value[10]}, {x:11,y:variable('a').value[12]}]
    property var oddPoints: [{x:-2,y:variable('a').value[0]}, {x:2,y:variable('a').value[3]}, {x:4,y:variable('a').value[5]}, {x:6,y:variable('a').value[7]}, {x:8,y:variable('a').value[9]}, {x:10,y:variable('a').value[11]}, {x:12,y:variable('a').value[13]}]

    display: Rectangle {
        color: 'white'
        border.color: '#1B1B1B'
        border.width: 1.5
        anchors.fill: parent
        clip: true
        Repeater {
            model: [evenPoints, oddPoints]
            Item {
                id: graph
                x: (parent.width - width)/2
                y: parent.border.width + index*height
                width: parent.width - parent.border.width*2
                height: .5*(parent.height - parent.border.width*2)
                property var points: modelData
                property var pMin: ({x: -3, y: -.1})
                property var pMax: ({x: 13, y: 1.1})
                property var  toView: p => ({ x: 'x' in p ? (p.x - pMin.x) / (pMax.x-pMin.x) * width : 0,
                                                y: 'y' in p ? height - (p.y - pMin.y) / (pMax.y-pMin.y) * height: 0 })

                property var toModel: p => ({ x: 'x' in p ? p.x * (pMax.x - pMin.x) / width + pMin.x : 0,
                                                y: 'y' in p ? (height - p.y)*(pMax.y-pMin.y) / height + pMin.y : 0 })

                Repeater {
                    model: [-2, 0, 2, 4, 6, 8, 10 ]
                    Rectangle { color: '#A0444444'; width: modelData == 0 ? 0.75 : 0.25 ; height: graph.height; y: 0; x: graph.toView({ x:modelData }).x - width/2 }
                }
                Repeater {
                    model: [0.8, 0.6, 0.4, 0.2, 0]
                    Rectangle { color: '#A0444444'; height:  modelData == 0 ? 0.75 : 0.25 ;  width: graph.width; x: 0; y: graph.toView({ y:modelData }).y - height/2 }
                }
                OhmText {
                    x: 1; y: 1;
                    color: 'black'
                    font.pixelSize: 4
                    text: (index == 0 ? 'Even' : 'Odd') + ' Fourier Coefficients'
                }
                Shape {
                    anchors.fill: parent
                    ShapePath {
                        id: spath
                        strokeWidth: 1
                        strokeColor: 'blue'
                        fillColor: 'transparent'
                        joinStyle: ShapePath.RoundJoin
                        strokeStyle: ShapePath.SolidLine
                        property var ps: [{x:graph.pMin.x,y:0}].concat(graph.points.slice(0,1)).concat({x:0,y:1}).concat(graph.points.slice(1)).concat({x:graph.pMax.x, y:0}).map(graph.toView)
                        startX: ps[0].x; startY: ps[0].y
                        pathElements: Array.from(Array(ps.length-1).keys()).map(i => Qt.createQmlObject(`import QtQuick 2.14; PathCubic { x: ${ ps[i+1].x }; y: ${ ps[i+1].y }; control1X: ${ ps[i].x }; control2X: ${ ps[i+1].x }; control1Y: ${ graph.toView({y:0}).y }; control2Y: control1Y}`,spath,""))
                    }
                }
                Repeater {
                    id: repeater
                    model: graph.points
                    Rectangle {
                        id: pointMark
                        color: Material.color(Material.Red, Material.Shade800)
                        property var pos: graph.toView({x: modelData.x, y: modelData.y})
                        x: pos.x - radius
                        y: pos.y - radius
                        width: 5; height: 5; radius: 2.5;
                        MouseArea {
                            x: -parent.width; y: -parent.width
                            width: parent.width*3; height: parent.height*3
                            cursorShape: enabled ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.ArrowCursor
                            drag.target: pointMark
                            drag.axis: Drag.YAxis
                            drag.minimumY: graph.toView({y:1}).y-pointMark.radius
                            drag.maximumY: graph.toView({y:0}).y-pointMark.radius
                            drag.threshold: 0
                            preventStealing: true; propagateComposedEvents: true; hoverEnabled: true
                            onPressed: mouse.accepted= true
                            onReleased: {
                                const xval = graph.points[index].x
                                const vidx = xval === -2 ? 0 : (xval === -1 ? 1 : xval+1 )
                                variable('a').value[vidx] = graph.toModel({y: pointMark.y+pointMark.radius}).y
                                variable('a').value = variable('a').value;
                            }
                        }
                    }
                }
            }
        }
    }
}
