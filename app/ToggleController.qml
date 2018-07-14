import QtQuick 2.11
import QtQuick.Controls 2.4

Controller {
    id: sw
    clickHandler: function(mouse) {
        if (indicatorItem.toggleTip.flip)
            indicatorItem.toggleTip.flip = false;
        else indicatorItem.toggleTip.flip = true;
    }
    indicator: Item {
        property alias toggleTip: toggleTip
        Image {
            width: 3.5; height: 3.1
            source: "ui/icons/togglebase.png"
            mipmap: true
            smooth: true
            x: (sw.width-width)/2
            y: (sw.height-height)*.5
            Image {
                id: toggleTip
                width: 2.3
                height: 3.5
                source: "ui/icons/toggletip.png"
                x: (parent.width-width)/2*1.8
                y: (parent.height/2-height)*.85
                property bool flip: controlVolts < 1
                onFlipChanged: controlVolts = flip ? 0 : 10

                property double txy: flip ? -0.85 : 1
                Behavior on txy {
                    PropertyAnimation {
                        easing.type: Easing.OutBounce
                        easing.overshoot: 1.8
                        easing.amplitude: .5
                        duration: 400
                    }
                }
                transform: [
                    Matrix4x4 {
                        matrix: Qt.matrix4x4(1,0,0,0,0,
                                             toggleTip.txy,0,
                                             (1-toggleTip.txy)*toggleTip.height*.92,
                                             0,0,1,0,0,0,0,1);
                    }
                ]
            }
        }
    }
}

