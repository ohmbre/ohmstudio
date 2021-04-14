import QtQuick

Module {
    id: audioIn
    label: 'Audio In'
    tags: ['hw']


    OutJack { label: 'ch1'; func: AUDIO.getInChannel(0); }
    OutJack { label: 'ch2'; func: AUDIO.getInChannel(1); }
    OutJack { label: 'ch3'; func: AUDIO.getInChannel(2); }
    OutJack { label: 'ch4'; func: AUDIO.getInChannel(3); }

    display: OhmText {
        text: "To change audio output, see Menu -> Audio Devices"
    }
    
}


