import QtQuick 2.11
import QtWebSockets 1.1
import QtWebEngine 1.7

WebSocketServer {
    id: sock
    listen: true
    property WebSocket ws
    signal statusChanged(var status)
    signal binaryMessageReceived(var message)
    signal textMessageReceived(string message)
    
    onClientConnected: function(webSocket) {
	ws = webSocket
	ws.statusChanged.connect(statusChanged)
	ws.binaryMessageReceived.connect(binaryMessageReceived)
	ws.textMessageReceived.connect(textMessageReceived)
	while (backlog.length) {
            var msg = backlog.shift()
            ws.sendTextMessage(msg)
        }
    }				 
    
    property var backlog: []

    function msg(msgObj) {
        var textMsg = JSON.stringify(msgObj)
        if (ws) ws.sendTextMessage(textMsg)
        else backlog.push(textMsg)
    }

    onStatusChanged: {
	console.log('status change', status)
        switch (status) {
        case WebSocket.Error:
            console.error(name,'sock error:',errorString)
            break
        case WebSocket.Closed:
            console.error(name,'socket closed')
            break
        case WebSocket.Open:
            console.log(name,'opened socket')
            break
        case WebSocket.Connecting:
        case WebSocket.Closing:
        default:
            break
        }
    }

    
    property WebEngineView webView: WebEngineView {
        id: webView
	url: "about:blank"
	userScripts: [
	    WebEngineScript {
		id: mathScript
		injectionPoint: WebEngineScript.DocumentCreation
		name: 'math'
		sourceUrl: 'math.min.js'
		worldId: WebEngineScript.MainWorld
	    },
	    WebEngineScript {
		id: engineScript
		injectionPoint: WebEngineScript.DocumentReady
		name: 'ohm'
		sourceUrl: 'ohm.js6'
		worldId: WebEngineScript.MainWorld	
	    },
	    WebEngineScript {
		id: initScript
		injectionPoint: WebEngineScript.Deferred
		name: 'init'
		sourceCode: "window.ohm=o(60600);"
		worldId: WebEngineScript.MainWorld
	    }
	]
	onJavaScriptConsoleMessage: function(level,message,lineNumber,sourceID) {
	    console.log(sourceID,'line',lineNumber,':',message)
	}
    }

}
