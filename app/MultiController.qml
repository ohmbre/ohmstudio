import QtQuick 2.11
import QtQuick.Controls 2.4

Controller {
    id: multiknob
    anchors.fill: parent
    indicator: Image {
        width: 5; height: width;
        source: "qrc:/app/ui/icons/multiknob.png"
        mipmap: true
        smooth: true
        x: (multiknob.width-width)/2
	y: (multiknob.height - height)*.6
    }

    editor: Item {
        anchors.fill: parent
        OhmText {
            x:parent.width*2/3
            y:parent.height*2/3
            text: controlVolts.toFixed(3)+' V'
            font.pixelSize: 12
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignLeft
            color: Style.sliderColor
        }
        OhmText {
            x:parent.width/5
            y:parent.height/4
            text: reading
            font.pixelSize: 12
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignLeft
            color: Style.sliderColor
        }
        Slider {
            id: slider
            rotation: -26
            value: controlVolts;
            from: -10; to: 10
            onValueChanged: {
                controlVolts = value
            }
            anchors.fill: parent
            background: Rectangle {
                x: slider.leftPadding; y: slider.topPadding + slider.availableHeight/2 - height / 2
                implicitWidth: 5
                implicitHeight: 100
                width: slider.availableWidth
                height: 5
                color: Style.sliderColor
                radius: 2
                Rectangle {
                    x: ((slider.visualPosition > .5) ? .5 : (slider.visualPosition+.02))*parent.width
                    width: ((slider.visualPosition > .5) ? (slider.position-0.5) :
                                                          (0.47-slider.visualPosition)) * parent.width
                    height: parent.height
                    color: Style.sliderLitColor
                    radius: 2
                }
                Rectangle {
                    x: parent.width/2-3; y:-3
                    width: 4
                    height:10
                    color: Style.darkText
                    radius: 2
                }
                Repeater {
                    model: 11
                    OhmText {
                        text: (index - 5)*2 + ((index==0||index==10)? 'V':'')
                        x: slider.leftPadding+2+index*parent.width/10.9-contentWidth/2
                        y: slider.topPadding
                        font.pixelSize: 7
                        color: Style.sliderColor
                    }
                }

            }
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: slider.pressed ? Style.sliderHandleLitColor: Style.sliderHandleColor
                border.color: Style.buttonBorderColor
            }
        }
    }
}

