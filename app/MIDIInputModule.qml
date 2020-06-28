import QtQuick 2.15
import ohm 1.0


Module {
    id: midiin
    label: "MIDI In"


    OutJack { label: "voct1"; outFunc: midiin.hw.getVoct(0) }
    OutJack { label: "gate1"; outFunc: midiin.hw.getGate(0) }
    OutJack { label: "vel1"; outFunc: midiin.hw.getVel(0) }
    OutJack { label: "voct2"; outFunc: midiin.hw.getVoct(1) }
    OutJack { label: "gate2"; outFunc: midiin.hw.getGate(1) }
    OutJack { label: "vel2"; outFunc: midiin.hw.getVel(1) }
    OutJack { label: "voct3"; outFunc: midiin.hw.getVoct(2) }
    OutJack { label: "gate3"; outFunc: midiin.hw.getGate(2) }
    OutJack { label: "vel3"; outFunc: midiin.hw.getVel(2) }
    OutJack { label: "cv"; outFunc: midiin.hw.getCv() }


    property var hw: new MIDIInFunction();
    function eventCallback(ev) {
        console.log(ev.type,ev.channel,ev.key,ev.val)
    }
    property var devChoice: -1
    onDevChoiceChanged: {
        if (devChoice === -1) return;
        midiin.hw.open(devChoice)
        midiin.hw.setJSCallback(midiin.eventCallback);
    }
    property var chanList:  [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
    property var msgList: ['Note On','Note Off','Ctrl Change','Pitch Wheel']
    property var keyList: Array.from(Array(128).keys())

    property var chanChoices: chanList.slice()
    property var msgChoices: msgList.slice()
    property var keyChoices: keyList.slice()

    Component.onCompleted: {
        hw.setChanFilter(chanChoices)
        hw.setTypeFilter(msgChoices)
        hw.setKeyFilter(keyChoices)
    }

    qmlExports: ({objectName: 'objectName', x:'x', y:'y', cvs: 'default', devChoice: 'devChoice', chanChoices: 'chanChoices', msgChoices: 'msgChoices', keyChoices: 'keyChoices'})

    display: Rectangle {
        anchors.fill: parent
        OhmChoiceBox {
            id: devChoice
            width: 150
            height: 16
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            label.text: "Device"
            control.currentIndex: midiin.devChoice
            choiceLabels: midiin.hw.listDevices()
            onChosen: midiin.devChoice = index
        }

        OhmChoiceArea {
            id: chanChoice
            model: midiin.chanList
            choices: midiin.chanChoices
            anchors.top: devChoice.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 7
            itemHeight: 8
            itemWidth: 8
            layout.rows: 2
            layout.columns: 8
            heading: 'Channel Filter'
            onChosen: midiin.hw.setChanFilter(choices)
        }

        OhmChoiceArea {
            id: msgChoice
            model: midiin.msgList
            choices: midiin.msgChoices
            anchors.top: chanChoice.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 13
            itemHeight: 8
            itemWidth: 30
            layout.rows: 7
            layout.columns: 1
            heading: 'Message Filter'
            onChosen: midiin.hw.setTypeFilter(choices)
        }

        OhmChoiceArea {
            id: keyChoice
            model: midiin.keyList
            choices: midiin.keyChoices
            anchors.top: msgChoice.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 13
            itemHeight: 8
            itemWidth: 8
            layout.rows: 4
            layout.columns: 32
            heading: 'Key Filter'
            onChosen: midiin.hw.setKeyFilter(choices)

        }

    }

}
