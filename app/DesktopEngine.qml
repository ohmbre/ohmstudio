import QtQuick 2.11
import QtWebEngine 1.7

WebEngineView {
    url: "http://localhost:60600/native.html"
    audioMuted: false
    onFeaturePermissionRequested: grantFeaturePermission(
	securityOrigin, feature, true) 
    onJavaScriptConsoleMessage: print(sourceID,'line',lineNumber,':',message)
    Component.onCompleted: {
	WebEngine.settings.allowRunningInsecureContent = true
	WebEngine.settings.allowWindowActivationFromJavaScript = true
	WebEngine.settings.localContentCanAccessFileUrls = true
	WebEngine.settings.localContentCanAccessRemoteUrls = true
	WebEngine.settings.playbackRequiresUserGesture = false
	WebEngine.settings.pluginsEnabled = true
    }
}
