import QtQuick 2.11
import ohm 1.0

Module {

    id: oscope
    objectName: 'OscopeModule'
    label: 'Scope'

    inJacks: [
        InJack { label: 'signal' },
        InJack { label: 'trig' }
    ]

    cvs: [
        LinearCV {
            label: 'vtrig'
            inVolts: 0
            from: 0
        },
        LogScaleCV {
            label: 'window'
            logBase: 1.2
            inVolts: 0
            from: '150ms'
        }
    ]

    property var signal: inStream('signal')
    property var trig: inStream('trig')
    property var vtrig: cvStream('vtrig')
    property var win: cvStream('window')
    property Timer setStreamDelayed: Timer {
        interval: 200; running: false; repeat: false;
        onTriggered: {
            engine.setStream('scope',signal)
            engine.setStream('scopeTrig',trig)
            engine.setStream('scopeVtrig',vtrig)
            engine.setStream('scopeWin',win)
        }
    }

    onSignalChanged: setStreamDelayed.restart()
    onTrigChanged: setStreamDelayed.restart()
    onVtrigChanged: setStreamDelayed.restart()
    onWinChanged: setStreamDelayed.restart()

    Component.onCompleted: {
        if (!oscope.parent)
            parentChanged.connect(function() {
                if (!oscope.parent.view)
                    oscope.parent.viewChanged.connect(function() {
                        oscope.parent.view.moduleDisplay = scopeDisplay
                    });
                else oscope.parent.view.moduleDisplay = scopeDisplay
            })
        else {
            if (!oscope.parent.view)
                oscope.parent.viewChanged.connect(function() {
                    oscope.parent.view.moduleDisplay = scopeDisplay
                });
            else oscope.parent.view.moduleDisplay = scopeDisplay
        }
    }

    property Component scopeDisplay: OhmScope {
        channelColor: '#7df9ff'
        bgColor: 'transparent'
        trig: cvs[0].controlVolts * 12.7
        win: cvs[1].reading

        function enter() {
            engine.enableScope(this)
        }

        function exit() {
            engine.disableScope()
        }

        function dataCallback(data) {
            this.buffer = new Int8Array(data);
            requestPaint()
        }
    }
}





