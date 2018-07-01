
Jack {
    objectName: "InJack"
    dir: "inp"

    property string defaultStream: '0'
    stream: defaultStream

    signal cableRemoved(OutJack outJack)
    onCableRemoved: stream = defaultStream

    signal cableAdded(OutJack outJack)
    onCableAdded: stream = Qt.binding(function() {
        return outJack.parsedStream
    });

}