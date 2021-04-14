import QtQuick

Module {
    id: audioOut
    label: 'Audio Out'
    tags: ['hw']

    InJack {
        label: 'ch1';
        onInFuncUpdated: function (lbl,func) {
           AUDIO.setOutChannel(0,func);
        }
    }
    InJack {
        label: 'ch2'
        onInFuncUpdated: function (lbl,func) {
           AUDIO.setOutChannel(1,func);
        }
    }
    InJack {
        label: 'ch3'
        onInFuncUpdated: function (lbl,func) {
            AUDIO.setOutChannel(2,func);
        }
    }
    InJack {
        label: 'ch4'
        onInFuncUpdated: function (lbl,func) {
            AUDIO.setOutChannel(3,func);
        }
    }

    display: OhmText {
        text: "To change audio output, see Menu -> Audio Devices"
    }

}


