import ohm.jack 1.0
import ohm.jack.out 1.0

Jack {
    objectName: "InJack"
    dir: "inp"
    property real volts: 0

    signal updateVolts(real newVolts)
    onUpdateVolts: {
      volts = newVolts;
    }

    signal cableRemoved(OutJack outJack)
    onCableRemoved: {
      outJack.voltsChanged.disconnect(updateVolts);
    }

    signal cableAdded(OutJack outJack)
    onCableAdded: {
      outJack.voltsChanged.connect(updateVolts);
    }

}
