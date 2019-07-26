import QtQuick 2.11

Item {
    id: engine

    function set(key, val) {
        var msg = JSON.stringify({ cmd: 'set', key: key, val: val })
        SoundEngine.sendMsg(msg)
    }

    function setsubkey(key,subkey,val) {
        var msg = JSON.stringify({ cmd: 'set', key: key, subkey: subkey, val: val })
        SoundEngine.sendMsg(msg)
    }

    function updateControl(uuid,val) {
        setsubkey('control',uuid,val)
    }


}

