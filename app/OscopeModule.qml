import QtQuick 2.14
import ohm 1.0

Module {

    id: scopemod
    label: 'Scope'

    InJack { label: 'ch1' }
    InJack { label: 'ch2' }

    CV { label: 'vtrig'; }
    CV {
        label: 'window';
        translate: v => 1000*1.3**(v-10)
        unit: 'ms'
    }



    display: Rectangle {
        color: 'white'
        border.color: '#4B4B4B'
        border.width: 1.5
        anchors.fill: parent

        Scope {
            id: scope
            anchors.fill: parent
            trig: scopemod.cv('vtrig').volts
            timeWindow: scopemod.cv('window').transVal
            Timer {
                interval: scopemod.cv('window').transVal
                running: true
                repeat: true
                onTriggered: {
                    scope.update()
                }
            }

            Component.onCompleted: {
                forEach(inJacks,(ij,i) => {
                    if (ij.inFunc) scope.setChannel(i, ij.inFunc);
                    ij.inFuncUpdated.connect((lbl,func) => { if (scope) scope.setChannel(i, func) })
                })
            }

        }

    }



}





