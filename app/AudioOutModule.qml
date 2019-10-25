import QtQuick 2.12
import ohm 1.0

Module {
    id: audioOut
    label: 'Audio Out'

    property var hw: null
    property var devChoices: []
    property var devChoice
    onDevChoiceChanged: {
        instantiate();
        if (devChoices.indexOf(devChoice) == -1) return;
        hw.setDevice(devChoice);
        audioOut.inJacks = []
        const nchan = hw.channelCount()
        console.log('devchoice changed w nchan',nchan)
        for (let i = 0; i < nchan; i++) {
            const pos = i
            var ijComponent = Qt.createComponent("qrc:/app/InJack.qml");
            if (ijComponent.status === Component.Ready) {
                const ij = ijComponent.createObject(audioOut, {label: pos, parent: audioOut})
                audioOut.inJacks.push(ij)
                ij.inFuncUpdated.connect((lbl,func) => { audioOut.hw.setChannel(parseInt(lbl), func) })
            } else
                console.log("error creating injack:", component.errorString());
        }

    }

    function instantiate() {
        if (!hw) {
            hw = new AudioOut();
            devChoices = hw.availableDevs();
        }
    }

    display: Item {
        OhmChoiceBox {
            width: 150
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label.text: "Device"
            choiceLabels: audioOut.devChoices
            control.currentIndex: audioOut.devChoices.indexOf(audioOut.devChoice);
            onChosen: {
                audioOut.devChoice = audioOut.devChoices[index]
            }
        }
    }
    qmlExports: ({objectName: 'objectName', x:'x', y:'y', devChoice:'devChoice'})

    Component.onCompleted: {
        instantiate();
    }
    Component.onDestruction: {
        if (hw) hw.destroy();
   }
}


