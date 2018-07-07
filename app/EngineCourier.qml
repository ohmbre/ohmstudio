import QtQuick 2.11

Item {
    id: courier
    property var backend: QtObject {
        id: nullEngine
        function msg() {
            return
        }
    }

    function set(key, val) {
        var msg = { cmd: 'set', key: key, val: val }
        backend.msg(JSON.stringify(msg))
    }

    function setsubkey(key,subkey,val) {
        var msg = { cmd: 'set', key: key, subkey: subkey, val: val }
        backend.msg(JSON.stringify(msg))
    }

    function updateControl(uuid,val) {
        setsubkey('control',uuid,val)
    }

    Component.onCompleted: {
        if (platform_name === 'web')
            backend = WasmCourier
        else backend = Qt.createQmlObject("NativeEngine {}", courier, "dyn");
    }

}

