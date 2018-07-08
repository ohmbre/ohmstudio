import QtQuick 2.11
import QtWebEngine 1.7

WebEngineView {
    audioMuted: false
    visible: false
    url: "http://localhost:60600/native.html"

    property var backlog: []
    property var msg: function(jsonStr) {
        backlog.push(jsonStr)
    }

    onFeaturePermissionRequested: function(securityOrigin,feature) {
        grantFeaturePermission(securityOrigin, feature, true)
    }

    onLoadingChanged: {
      if (loadRequest.status != WebEngineView.LoadSucceededStatus) return
      msg = function(jsonStr) {
	  runJavaScript("ohmengine.handle('%1')".arg(jsonStr))
      }
      while (backlog.length)
        msg(backlog.shift())
    }


    Component.onCompleted: {
        WebEngine.settings.pluginsEnabled = true
        WebEngine.settings.allowRunningInsecureContent = true
        WebEngine.settings.javascriptEnabled = true
        WebEngine.settings.localContentCanAccessFileUrls = true
        WebEngine.settings.localContentCanAccessRemoteUrls = true
        WebEngine.settings.localStorageEnabled = true
	WebEngine.settings.webGLEnabled = false
	WebEngine.settings.pluginsEnabled = false
	WebEngine.settings.autoLoadIconsForPage = false
	WebEngine.settings.accelerated2dCanvasEnabled = false
	WebEngine.settings.showScrollBars = false
	WebEngine.settings.spatialNavigationEnabled = false
    }

}
