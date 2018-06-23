import QtQuick 2.11

Item {
    visible: false

    property alias scope: scope
    property alias codec: codec
    
    OhmSocket { id: codec; name: 'codec'; port: 60600 }
    OhmSocket { id: scope; name: 'scope'; port: 54700 }

    function updateControl(id, controlVolts) {
	codec.msg({cmd:'set', key:'controls', subkey: parseInt(id), val: controlVolts})
	scope.msg({cmd:'set', key:'controls', subkey: parseInt(id), val: controlVolts})
    }
    
}
    
