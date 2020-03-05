import QtQuick 2.14
import ohm 1.0

Module {
    id: audioIn
    label: 'Audio In'

    property var hw: null
    property var devChoices: []
    property var devChoice
    onDevChoiceChanged: {
        instantiate();
        if (devChoices.indexOf(devChoice) == -1) return;
        hw.setDevice(devChoice);
        audioIn.outJacks = []
        const nchan = hw.channelCount()
        for (let i = 0; i < nchan; i++) {
            var ojComponent = Qt.createComponent("qrc:/app/OutJack.qml");
            if (ojComponent.status === Component.Ready) {
                const oj = ojComponent.createObject(audioIn, {label: i, parent: audioIn})
                audioIn.outJacks.push(oj)
                oj.outFunc = audioIn.hw.getChannel(i)
                oj.outFuncUpdated(oj.outFunc)
            } else
                console.log("error creating outjack:", ojComponent.errorString());
        }

    }

    function instantiate() {
        if (!hw) {
            hw = new AudioIn();
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
            choiceLabels: audioIn.devChoices
            control.currentIndex: audioIn.devChoices.indexOf(audioIn.devChoice);
            onChosen: {
                audioIn.devChoice = audioIn.devChoices[index]
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


