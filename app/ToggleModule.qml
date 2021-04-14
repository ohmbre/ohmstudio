import QtQuick

Module {

    label: 'Toggle'
    tags: ['trig/gate']
    BinaryCV { label: 'toggle' }

    OutJack {
        label: 'cv'
        calc: 'double calc() { return toggle; }'
    }
    
    preview: Item {
        property double volts: cv('toggle').volts
        property string displayLabel: ''
        onVoltsChanged: cv('toggle').volts = volts
        ToggleController { 
            x: parent.width*.2
            y: parent.height*.2
            width: parent.width*.6
            height: parent.height*.55
        }
               
    }

}
