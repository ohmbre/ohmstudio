import QtQuick

Module {
    id: audioOut
    label: 'Audio Out'

    InJack {
        label: 'ch1';
        onInFuncUpdated: function (lbl,func) {
           AUDIO_OUT.setChannel(0,func);
        }
    }
    InJack {
        label: 'ch2'
        onInFuncUpdated: function (lbl,func) {
           AUDIO_OUT.setChannel(1,func);
        }
    }
    InJack {
        label: 'ch3'
        onInFuncUpdated: function (lbl,func) {
            AUDIO_OUT.setChannel(2,func);
        }
    }
    InJack {
        label: 'ch4'
        onInFuncUpdated: function (lbl,func) {
            AUDIO_OUT.setChannel(3,func);
        }
    }

    tags: ['interface']

    display: OhmText {
        text: "To change audio output, see Menu -> Audio Out"
    }

}


