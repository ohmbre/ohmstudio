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

    property var webView
    property Timer setStreamDelayed: Timer {
        interval: 500; running: false; repeat: false
        onTriggered: {
            engine.debugView = webView
            checked(()=>{ engine.setStream('debug',debugStream) }, debugStream)
        }
    }
    onDebugStreamChanged: setStreamDelayed.restart()

    Component.onCompleted: {
        if (!debug.parent)
            parentChanged.connect(function() {
                if (!debug.parent.view)
                    debug.parent.viewChanged.connect(function() {
                        debug.parent.view.moduleDisplay = debug.display
                    });
                else debug.parent.view.moduleDisplay = debug.display
            })
        else {
            if (!debug.parent.view)
                debug.parent.viewChanged.connect(function() {
                    debug.parent.view.moduleDisplay = debug.display
                });
            else debug.parent.view.moduleDisplay = htmlDisplay
        }
    }


    property Component display: Rectangle {
        border.width: 1
        border.color: "blue"
        function enter() {}
        function exit() {}
        clip: false
        z:8
        transform: Scale {
            origin.x: 0; origin.y: 0;
            xScale: parent.width/512; yScale: parent.height/256
        }
        WebEngineView {
            width: 512
            height: 256*4/3
            z:9
            id: debugWebView
            transform: Scale {
                origin.x: 0; origin.y: 0
                xScale: 1; yScale: .75
            }
            zoomFactor: 0.5
        }

        Component.onCompleted: debug.webView = debugWebView
    }

}


