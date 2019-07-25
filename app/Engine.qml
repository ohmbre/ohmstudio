import QtQuick 2.11
import org.ohm.audio 1.0

Item {
    id: engine

    SoundWorker {
        id: worker
	source: "engine/worker.mjs"
    }

    function set(key, val) {
        var msg = JSON.stringify({ cmd: 'set', key: key, val: val })
        worker.sendMessage(msg)
    }

    function setsubkey(key,subkey,val) {
        var msg = JSON.stringify({ cmd: 'set', key: key, subkey: subkey, val: val })
        worker.sendMessage(msg)
    }

    function updateControl(uuid,val) {
        setsubkey('control',uuid,val)
    }
   

}

