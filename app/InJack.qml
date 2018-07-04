
Jack {
    objectName: "InJack"
    dir: "inp"

    property var initStream: null
    property var stream: 0

    signal cableRemoved(OutJack outJack)
    onCableRemoved: stream = (initStream === null) ? 0 : initStream
    

    signal cableAdded(OutJack outJack)
    onCableAdded: {
	if (initStream == null)
	    initStream = stream
	stream = Qt.binding(function() {
            return outJack.parsedStream
	})
    }

}
