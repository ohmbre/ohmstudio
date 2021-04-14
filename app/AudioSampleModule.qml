import QtQuick
import QtQuick.Controls
import Qt.labs.platform


Module {
    id: audioSample
    label: 'Play Sample'
    tags: ['sample']

    InJack { label: 'trig' }
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 1.**v
    }
    CV {
        label: 'ctrlGain'
        volts: 3
    }

    Variable { label: 'samples'; value: [0] }
    OutJack {
        label: 'out'
        calc: `double t = DBL_MAX;
               bool was_hi = false;
               double calc() {
                   bool hi = trig > 3;
                   if (hi && !was_hi) t = 0;
                   was_hi = hi;
                   double step = pow(2.,inFreq+ctrlFreq);
                   double sample = 0;
                   if (t < samples.size()) {
                       long maxidx = samples.size()-1;
                       if (step <= 1) {
                           sample = samples[clamp((long)round(t), 0l, maxidx)];
                       } else {
                           long idx0 = clamp((long)round(t-step/2), 0l, maxidx);
                           long idx1 = clamp((long)round(t+step/2), 0l, maxidx);
                           long i = idx0;
                           while (i <= idx1)
                               sample += samples[i++];
                           sample = sample / (i-idx0);
                       }
                   }
                   t += step; 
                   return (inGain + ctrlGain) * sample;
               }`//'
    }

    property var fileName: null
    onFileNameChanged: {
        if (fileName != null) {
            const samples = MAESTRO.samplesFromFile(fileName);
            variable('samples').value = samples
        } else {
            variable('samples').value = [0]
        }
    }

    exports: ({ x:'x', y:'y', cvs:'default', fileName: 'fileName'})

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
            acceptLabel: "load"
            title: "Choose file containing audio sample"
            onAccepted: {
                audioSample.fileName = file
                fileDialog.close();
            }
            onRejected: {
                fileDialog.close()
            }
        }

    }
}
