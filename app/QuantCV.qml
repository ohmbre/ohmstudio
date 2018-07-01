CV {
    objectName: "QuantCV"

    property var choices
    onControlVoltsChanged: {
        controlVolts = Math.round(((controlVolts+10)/20)*choices.length)/choices.length*20-10
        engine.updateControl(uuid(), controlVolts)
    }
    knobReading: stream

    stream: choices[
                Math.max(Math.min(Math.round(((controlVolts+10)/20)*choices.length),choices.length-1),0)
            ].toString()


}
