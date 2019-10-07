import QtQuick 2.12
import ohm 1.0

Module {
    id: audioOutModule
    label: 'Audio Out'

    property var hw: null
    onHwChanged: {
        audioOutModule.inJacks = []
        if (hw == null) return;
        const nchan = hw.channelCount()
        for (let i = 0; i < nchan; i++) {
            const pos = i
            var ijComponent = Qt.createComponent("qrc:/app/InJack.qml");
            if (ijComponent.status === Component.Ready) {
                const ij = ijComponent.createObject(audioOutModule, {label: pos, parent: audioOutModule})
                audioOutModule.inJacks.push(ij)
                ij.inFuncUpdated.connect((lbl,func) => { audioOutModule.hw.setChannel(parseInt(lbl), func) })
            } else
                console.log("error creating injack:", component.errorString());
        }

    }

    property var devChoice
    onDevChoiceChanged: {
        currentChoiceIndex = AudioHWInfo.availableOutDevs().indexOf(devChoice)
        if (hw != null) {
            hw.destroy();
            hw = null;
        }

        if (currentChoiceIndex >= 0)
            hw = AudioHWInfo.createOutput(devChoice);
        userChanges()
    }
    property var currentChoiceIndex: -1
    display: Item {
        OhmChoiceBox {
            width: 150
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label.text: "Device"
            control.currentIndex: audioOutModule.currentChoiceIndex
            choiceLabels: AudioHWInfo.availableOutDevs()
            onChosen: {
                audioOutModule.devChoice = choiceLabels[index]
            }
        }
    }
    qmlExports: ({x:'x', y:'y', devChoice:'devChoice'})

    Component.onDestruction: {
        if (hw!= null) {
            hw.destroy();
            hw = null;
        }
    }
}


