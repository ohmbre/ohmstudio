import QtQuick 2.11

Item {
    id: engine

    function set(key, val) {
        engine.sendMsg({ cmd: 'set', key: key, val: val })
    }

    function setsubkey(key,subkey,val) {
        engine.sendMsg({ cmd: 'set', key: key, subkey: subkey, val: val })
    }

    function sendMsg(msg) {
        try {
            ohm.handleMsg(msg)
        } catch (err) {
            console.error(err);
            console.error(err.stack)
        }
    }

    function updateControl(uuid,val) {
        setsubkey('control',uuid,val)
    }


}

