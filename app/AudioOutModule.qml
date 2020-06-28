import QtQuick 2.15
import ohm 1.0

Module {
    id: audioOut
    label: 'Audio Out'

    property var hw: new AudioOut();

    property string devId: ""

    function deleteJacks() {
        const ijs = mapList(inJacks, j => j)
        audioOut.inJacks = []
        for (let ij of ijs) ij.destroy()
    }

    function switchDev(newId) {
        if (devId === newId || newId === "") return;
        if (devId != "") {
            deleteJacks();
        }
        devId = newId;
    }

    onDevIdChanged: {
        if (devId == "") return;
        if (hw.setDevice(devId) === false) {
            console.error("problem finding device:", devId);
            deleteJacks();
            devId = "";
            return;
        }
        const nchan = hw.channelCount()
        for (let i = 0; i < nchan; i++) {
            audioOut.hw.setChannel(i, null);
            const pos = i
            var ijComponent = Qt.createComponent("qrc:/app/InJack.qml");
            if (ijComponent.status === Component.Ready) {
                const ij = ijComponent.createObject(audioOut, {label: pos, parent: audioOut})
                audioOut.inJacks.push(ij)
                ij.inFuncUpdated.connect((lbl,func) => { audioOut.hw.setChannel(parseInt(lbl), func) })
            } else
                console.log("error creating injack:", ijComponent.errorString());
        }
    }

    display: Item {
        OhmChoiceBox {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            label: "Device"
            model: audioOut.hw.availableDevs();
            choice: audioOut.devId
            onChosen: function(newId) {
                audioOut.switchDev(newId);
            }
        }
    }
    qmlExports: ({objectName: 'objectName', x:'x', y:'y', devId:'devId'})

    Component.onDestruction: {
        if (hw) hw.destroy();
    }
}


