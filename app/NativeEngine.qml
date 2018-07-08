import QtQuick 2.11
import QtWebView 1.1

WebView {

    url: "http://localhost:60600/native.html"

    property var backlog: []
    property var msg: function(jsonStr) {
        backlog.push(jsonStr)
    }

    onLoadingChanged: {
      if (loadRequest.status != WebView.LoadSucceededStatus) return
      msg = function(jsonStr) {
	  runJavaScript("ohmengine.handle('%1')".arg(jsonStr))
      }
      while (backlog.length)
        msg(backlog.shift())
    }

}
