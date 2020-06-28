import QtQuick 2.15
import ohm 1.0

Module {

    id: fftmod
    label: 'Spectrum'

    InJack { label: 'input' }
    display: Item {
        anchors.fill: parent
        Rectangle {
            color: 'white'
            border.color: '#4B4B4B'
            border.width: 1.5
            radius: 2

            width: parent.width
            height:parent.height*1.3
            FFTScope {
                anchors.fill: parent
                id: fft
                Timer {
                    interval: 200
                    running: true
                    repeat: true
                    onTriggered: {
                        fft.update()
                    }
                }
            }
            Connections {
                target: fftmod
                Component.onCompleted: {
                    if (fftmod.jack('input').inFunc)
                        fft.setChannel(0, fftmod.jack('input').inFunc);
                    fftmod.jack('input').inFuncUpdated.connect((lbl,func) => { fft.setChannel(0, func) })
                }
            }
        }
    }
}





