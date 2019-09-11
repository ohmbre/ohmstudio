CV {
    id: logcv
    objectName: "LogScaleCV"

    property var logBase: 2
    property var from: 1
    unitStream: v => `(${from} * ${logBase}^${v})`
}
