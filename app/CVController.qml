import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Shapes 1.12
import QtQuick.Controls.Material 2.12

Item {
    width: 200
    height: 24
    OhmText {
        color: 'white'
        x: 0; y: parent.height/2-height; width: 40; height: 8
        text: displayLabel
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 8
    }

    Item {
        x: 60
        width: 100
        height: 24
        scale: 1.3

        OhmText {
            color: Material.color(Material.Grey, Material.Shade800)
            x:-3; y:parent.height/2-1; width: 6; height: 4
            font.pixelSize: 3
            text: '-10V'
            horizontalAlignment: Text.AlignLeft
        }

        OhmText {
            color: Material.color(Material.Grey, Material.Shade800)
            x:parent.width/2-3; y:parent.height/2-1; width: 6; height: 4
            font.pixelSize: 3
            text: '0V'
            horizontalAlignment: Text.AlignHCenter
        }

        OhmText {
            color: Material.color(Material.Grey, Material.Shade800)
            x:parent.width-4; y:parent.height/2-1; width: 6; height: 4
            font.pixelSize: 3
            text: '10V'
            horizontalAlignment: Text.AlignRight
        }




        Slider {
            id: control
            width: parent.width; height: 18
            rightPadding: 0
            bottomPadding: 0
            leftPadding: 0
            topPadding: 0
            value: controlVolts;
            from: -10; to: 10
            onValueChanged: {
                controlVolts = value
            }
            orientation: Qt.Horizontal
            snapMode: Slider.SnapOnRelease

            background: Item {
                z: 0
                Rectangle {
                    x: 0; y: (control.height - height)/2; width: control.width; height: 2;
                    color: Material.color(Material.Grey, Material.Shade400)
                    radius: height/2
                    Rectangle {
                        x: 0; y: (parent.height - height)/2; z: 0
                        width: control.position * parent.width
                        height: 3
                        radius: height/2
                        color: Material.color(Material.Red, Material.Shade300)
                    }
                }
                Repeater {
                    model: 21
                    Rectangle {
                        x: index*(control.width-3)/20-width/2+1.5
                        y: (parent.height - height) / 2
                        z: 2
                        width: .5; height: (index % 10) ? (index % 2 ? 1.5 : 3) : 5
                        color: Material.color(Material.Grey, Material.Shade800)
                    }
                }
                Rectangle {
                    x: control.visualPosition * (control.width - width); y: (control.height-height)/2
                    width:3; height: width; radius: width/2; z: 1
                    color: Material.color(Material.Red, Material.Shade800)
                }

            }

            handle: Rectangle {
                z: 1
                scale: control.pressed ? 2 : 1
                Behavior on scale { NumberAnimation { duration: 250 } }
                x: control.visualPosition * (control.width - 3) - width/2 + 1.5;
                y: (control.height - height) /2; width: 9; height: width;
                radius: width/2
                color: '#33222222'

                OhmText {
                    color: 'white'
                    x:(parent.width-width)/2; y:-5; width: 15; height: 4;
                    font.pixelSize: 4
                    text: dispUnits(controlVolts)
                    horizontalAlignment: Text.AlignHCenter
                    function dispUnits(v) {
                        let [num,unit] = evaluate(v)
                        let mag = Math.abs(num)
                        if (mag >= 100) num = Math.round(num)
                        else if (mag >= 10) num = Math.round(num*10)/10
                        else if (mag >= 1) num = Math.round(num*100)/100
                        else if (mag > 0) num = (Math.round(num*1000)/1000).toString().slice(1)
                        return num+' '+unit
                    }
                }

                OhmText {
                    color: 'white'
                    x:(parent.width-width)/2; y:9.5; width: 15; height: 4;
                    font.pixelSize: 4
                    text: controlVolts.toFixed(2) + ' V'
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
