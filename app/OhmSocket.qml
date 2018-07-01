import QtQuick 2.11
import QtWebSockets 1.1

WebSocket {
    id: sock
    active: true
    url: "ws://localhost:%1/".arg(port)
    
    property string name
    property int port
    property var backlog: []
        
    function msg(msgObj) {
	var textMsg = JSON.stringify(msgObj)
	if (status == WebSocket.Open)
	    sendTextMessage(textMsg)
	else
	    backlog.push(textMsg)
    }

    onStatusChanged: {
	switch (status) {
	    case WebSocket.Error:
	        console.error(name,'sock error:',errorString)
	        break
	    case WebSocket.Closed:
	        console.error(name,'socket closed')
	        break
	    case WebSocket.Open:
	        console.log(name,'opened socket')
	        while (backlog.length) {
		    var msg = backlog.shift()
		    sendTextMessage(msg)
	        }
	        break
	    case WebSocket.Connecting:
	    case WebSocket.Closing:
	    default:
	        break
	}
    }
    Component.onCompleted: {
	console.log(name,'sock completed component')
    }
    Component.onDestruction: {
	console.log(name,'destroying websocket')
    }
}
