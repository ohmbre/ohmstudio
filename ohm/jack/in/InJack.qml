import ohm.jack 1.0
import ohm.jack.out 1.0

Jack {
    objectName: "InJack"
    dir: "inp"

    property var defaultStream: repeat(0);
    stream: defaultStream
    
    signal cableRemoved(OutJack outJack)
    onCableRemoved: stream = defaultStream
  
    signal cableAdded(OutJack outJack)
    onCableAdded: stream = Qt.binding(function() {return outJack.stream});

}
