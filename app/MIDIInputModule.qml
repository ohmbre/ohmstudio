import QtQuick 2.12
import ohm 1.0


Module {
    id: midiin
    label: "MIDI In"

    OutJack { label: "cv"; outFunc: midiin.hw }

    property var choiceIdx: -1
    property var hw: new MIDIInFunction();
    function eventCallback(ev) {
        console.log(ev.type,ev.channel,ev.key,ev.val)
        eventText = JSON.stringify(ev)
    }
    property var eventText: "[no event]"


    display: Item {

        OhmChoiceBox {
            width: 150
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label.text: "Device"
            control.currentIndex: midiin.choiceIdx
            choiceLabels: midiin.hw.listDevices()
            onChosen: {
                midiin.hw.setJSCallback(midiin.eventCallback);
                midiin.hw.open(index)

            }
        }

        OhmText {

            color: 'black'
            text: midiin.eventText
        }

    }

}
