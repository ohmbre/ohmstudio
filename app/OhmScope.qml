import QtQuick 2.11

Canvas {
    id: scope
    canvasSize: Qt.size(512,256)
    canvasWindow: Qt.rect(0,0,512,256)
    x: 0; y: 0
    antialiasing: true
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Cooperative
    transform: Scale {
        origin.x: 0; origin.y: 0;
        xScale: parent.width/512; yScale: parent.height/256
    }
    property var channelColor: 'red'
    property color bgColor: 'black'
    property var buffer: new Int16Array(512)
    property real trig: 0
    property string win
    property real trigOpacity: 0
    NumberAnimation { id: trigAnim; target: scope; property:'trigOpacity'; from: 1; to: 0; duration: 1000 }
    onTrigChanged: {
        trigOpacity = 1
        trigAnim.start()
        requestPaint()
    }


    onPaint: {
        var ctx = scope.getContext("2d");
        ctx.save();
        ctx.clearRect(0, 0, 512, 256);
        ctx.globalAlpha = 0.75
        ctx.lineWidth = 3
        ctx.strokeStyle = channelColor
        ctx.beginPath();
        ctx.moveTo(0,128-buffer[0]);
        for (let i=1; i < 512; i++) {
            ctx.lineTo(i, 128-buffer[i])
        }
        ctx.stroke();
        ctx.strokeStyle = Qt.rgba(128,128,0,trigOpacity)
        ctx.beginPath();

        ctx.moveTo(0,128-trig)
        ctx.lineTo(511,128-trig)
        ctx.stroke();
        ctx.fillStyle = 'white'
        ctx.font = 'bold 20px Asap'
        ctx.fillText('10v', 0, 15)
        ctx.fillText('0v', 0, 130)
        ctx.fillText('-10v', 0, 255)
        ctx.fillText(win,440,145)
        ctx.restore();
    }
}

