import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Shapes 1.12
import QtQuick.Controls.Material 2.12

Item {
    width: 200
    height: 24
    OhmText {
        color: 'black'
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




        OhmSlider {
            id: control
            width: parent.width; height: 18

            value: volts;
            onValueChanged: {
                volts = value
            }

            background: Item {
                antialiasing: true
                Rectangle {
                    x: 0; y: (control.height - height)/2; width: control.width; height: 2;
                    color: Material.color(Material.Grey, Material.Shade400)
                    radius: height/2
                    Rectangle {
                        x: 0; y: (parent.height - height)/2; z: 0
                        width: control.position * (control.width-3) +3
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
                    x: control.position * (control.width - width); y: (control.height-height)/2
                    width:3; height: width; radius: width/2; z: 1
                    color: Material.color(Material.Red, Material.Shade800)
                }

            }

            handle: Rectangle {
                z: 1
                antialiasing: true
                smooth: true
                scale: control.pressed ? 1.5 : 1
                Behavior on scale { NumberAnimation { duration: 250 } }
                x: control.position * (control.width - 3) - width/2 + 1.5;
                y: (control.height - height) /2; width: 9; height: width;
                radius: width/2
                color: '#33222222'

                OhmText {
                    visible: hasTranslation
                    color: 'black'
                    x:(parent.width-width)/2; y:-5; width: 20; height: 4;
                    font.pixelSize: 4
                    text: translation
                    horizontalAlignment: Text.AlignHCenter
                }

                OhmText {
                    color: 'black'
                    x:(parent.width-width)/2; y:9.5; width: 15; height: 4;
                    font.pixelSize: 4
                    text: volts.toFixed(2) + ' V'
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
