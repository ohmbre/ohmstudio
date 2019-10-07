import QtQuick 2.12
import ohm 1.0

Module {

    id: fftmod
    label: 'Spectrum'

    InJack { label: 'input' }
    property alias fftDisplay: fftDisplay
    display: Item {
        id: fftDisplay
        anchors.fill: parent
        property alias fftExpand: fftExpand
        Rectangle {
            id: fftExpand
            color: 'white'
            border.color: '#4B4B4B'
            border.width: 1.5
            radius: 2

            width: parent.width
            height:parent.height*1.3
            property alias fft: fft
            FFTScope {
                anchors.fill: parent
                id: fft
                Timer {
                    interval: 50
                    running: true
                    repeat: true
                    onTriggered: {
                        fft.update()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (jack('input').inFunc)
            fftDisplay.fftExpand.fft.setChannel(0, jack('input').inFunc);
        jack('input').inFuncUpdated.connect((lbl,func) => { fftDisplay.fftExpand.fft.setChannel(0, func) })
    }
}





