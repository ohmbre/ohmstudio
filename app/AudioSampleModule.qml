import ohm 1.0
import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3


Module {
    id: audioSample
    label: 'Play Sample'

    InJack { label: 'trig' }
    InJack { label: 'inFreq' }
    CV {
        label: 'ctrlFreq'
        translate: v => 2**v
    }
    Variable { label: 't'; value: 99999999 }
    Variable { label: 'gate' }
    Variable { label: 'sample'; value: [0] }
    OutJack {
        label: 'out'
        expression:
            't := (gate == 0) and (trig > 3) ? 0 : t + 2^(inFreq + ctrlFreq);
             gate := (trig > 3) ? 1 : 0;
             round(t) < sample[] ? sample[round(t)] : 0;'
    }

    property var fileName: null
    onFileNameChanged: {
        if (fileName != null)
            variable('sample').value = FileIO.samplesFromFile(fileName)
        else
            variable('sample').value = [0]
    }

    qmlExports: ({objectName: 'objectName', x:'x', y:'y', cvs:'default', fileName: 'fileName'})

    display: Item {
        anchors.fill: parent
        OhmButton {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 30
            text: "Choose File"
            font.pixelSize: 6
            onClicked: {
                fileDialog.open();
            }
        }

        OhmText {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 60
            color: 'black'
            font.pixelSize: 6
            text: fileName == null? '' : fileName
        }

        FileDialog {
            id: fileDialog
            title: "Choose audio file..."
            onAccepted: {
                fileName = fileDialog.fileUrl
                fileDialog.close();
            }
            onRejected: {
                fileDialog.close()
            }
        }

    }
}
