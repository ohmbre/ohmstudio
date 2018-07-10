import QtQuick 2.11
import QtWebView 1.1

Item {
    visible: false

    property var backlog: []

    property var msg: function (jsonStr) {
        backlog.push(jsonStr)
    }

    function handleLoad(status) {
        if (status !== WebView.LoadSucceededStatus)
            return
        msg = function (jsonStr) {
            engineload.item.runJavaScript(
                        "window.ohmengine.handle('%1')".arg(jsonStr))
        }
        while (backlog.length)
            msg(backlog.shift())
    }

    Loader {
        id: engineload
        source: (Qt.platform.os == 'ios'
                 || Qt.platform.os == 'android') ? 'MobileEngine.qml' : 'DesktopEngine.qml'
    }

    Connections {
        target: engineload.item
        onLoadingChanged: handleLoad(loadRequest.status)
    }
}
