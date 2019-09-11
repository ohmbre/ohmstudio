import QtQuick 2.11


Rectangle {
    id: display
    color: '#444444'
    radius: 3
    clip: true
    anchors.fill: parent

    //anchors.fill: parent
    property var signalStream: null
    property var trigStream: null
    property var vtrigStream: null
    property var winStream: null
    property real trig: 0
    property string win: ""

    property real trigOpacity: 0
    property Timer setStreamDelayed: Timer {
        interval: 200; running: false; repeat: false;
        onTriggered: {
            engine.setStream('scopeSignal',signalStream)
            engine.setStream('scopeTrig',trigStream)
            engine.setStream('scopeVtrig',vtrigStream)
            engine.setStream('scopeWin',winStream)
        }
    }

    onSignalStreamChanged: setStreamDelayed.restart()
    onTrigStreamChanged: setStreamDelayed.restart()
    onVtrigStreamChanged: setStreamDelayed.restart()
    onWinStreamChanged: setStreamDelayed.restart()

    NumberAnimation { id: trigAnim; target: display; property:'trigOpacity'; from: 1; to: 0; duration: 1000 }
    onTrigChanged: {
        trigOpacity = 1
        trigAnim.start()
        scope.requestPaint()
    }

    Canvas {
        id: scope
        canvasSize: Qt.size(512,256)
        canvasWindow: Qt.rect(0,0,512,256)
        antialiasing: true
        renderTarget: Canvas.FramebufferObject
        transform: Scale {
            xScale: width/512
            yScale: height/256

        }

        property var buffer: new Int16Array(512)

        function dataCallback(data) {
            this.buffer = new Int8Array(data);
            requestPaint()
        }

        onPaint: {
            var ctx = scope.getContext("2d");
            ctx.save();
            ctx.clearRect(0, 0, 512, 256);
            ctx.globalAlpha = 0.75
            ctx.lineWidth = 3
            ctx.strokeStyle = '#7df9ff'
            ctx.beginPath();
            ctx.moveTo(0,128-buffer[0]);
            for (let i=1; i < 512; i++) {
                ctx.lineTo(i, 128-buffer[i])
            }
            ctx.stroke();
            ctx.strokeStyle = Qt.rgba(128,128,0,display.trigOpacity)
            ctx.beginPath();

            ctx.moveTo(0,128-display.trig)
            ctx.lineTo(511,128-display.trig)
            ctx.stroke();
            ctx.fillStyle = 'white'
            ctx.font = 'bold 20px Asap'
            ctx.fillText('10v', 0, 15)
            ctx.fillText('0v', 0, 130)
            ctx.fillText('-10v', 0, 255)
            ctx.fillText(display.win,440,145)
            ctx.restore();
        }
    }

    Component.onCompleted: {
        console.log("scope enter")
        engine.enableScope(scope)
    }
    Component.onDestruction: {
        console.log("scope exit")
        engine.disableScope(scope)
    }

}
