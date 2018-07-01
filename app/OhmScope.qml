import QtQuick 2.11

Canvas {
    id: scope
    canvasSize: Qt.size(512,256)
    canvasWindow: Qt.rect(0,0,512,256)
    x: 0; y: 0
    antialiasing: true
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Cooperative
    transform: Scale { origin.x: 0; origin.y: 0;
        xScale: parent.width/512; yScale: parent.height/256}
    property var channelColors: ['red','blue','green','yellow']
    property color bgColor: 'black'
    property var buffers
    property real trig: 0
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
        var window
        for (var ch = 0; ch < buffers.length; ch++) {
            var buf = buffers[ch]
            window = buf.truncate ? buf.truncate : buf.length
            if (window === 0) continue
            ctx.strokeStyle = channelColors[ch]
            ctx.beginPath();
            ctx.moveTo(0,128-buf[0]);
            const xinc = 512/window
            var x = xinc
            for (var i=1; i < window; i++) {
                ctx.lineTo(x, 128-buf[i])
                x += xinc
            }
            ctx.stroke();
        }
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
        ctx.fillText((Math.round(window/4.8)/10)+'ms',440,145)
        ctx.restore();
    }
}

