import QtQuick 2.11
import QtWebEngine 1.8
import ohm 1.0

Module {
    id: debug
    objectName: 'DebugModule'
    label: 'Debug'

    inJacks: [
        InJack { label: 'in' }
    ]

    property var debugStream: inStream('in')
    property var queued: null
    property var updateEngine: null
    onDebugStreamChanged: {
        if (updateEngine) updateEngine(debugStream);
        else queued = debugStream
    }

    display: Rectangle {
        border.width: 1
        border.color: "blue"
        clip: false
        transform: Scale {
            origin.x: 0; origin.y: 0;
            xScale: parent.width/512; yScale: parent.height/256
        }

        WebEngineView {
            width: 512
            height: 256*4/3
            id: debugWebView
            url: "about:blank"
            transform: Scale {
                origin.x: 0; origin.y: 0
                xScale: 1; yScale: .75
            }
            zoomFactor: 0.5
        }

        Component.onCompleted: {
            debug.updateEngine = (stream) => {
                checked(()=>{ engine.debugStream(stream, debugWebView) }, stream)
            }
            if (debug.queued) {
                debug.updateEngine(debug.queued)
                debug.queued = null;
            }
        }
        function enter() {}
        function exit() {}
    }

}


