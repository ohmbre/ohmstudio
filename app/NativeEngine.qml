import QtQuick 2.11
import QtWebEngine 1.7

WebEngineView {
    audioMuted: false
    visible: false
    url: "http://localhost:60600/native.html"

    function msg(jsonStr) {
        runJavaScript("window.ohmengine.handle('%1')".arg(jsonStr))
    }

    onFeaturePermissionRequested: function(securityOrigin,feature) {
        grantFeaturePermission(securityOrigin, feature, true)
    }

    Component.onCompleted: {
        WebEngine.settings.pluginsEnabled = true
        WebEngine.settings.allowRunningInsecureContent = true
        WebEngine.settings.javascriptEnabled = true
        WebEngine.settings.localContentCanAccessFileUrls = true
        WebEngine.settings.localContentCanAccessRemoteUrls = true
        WebEngine.settings.localStorageEnabled = true
    }

}
