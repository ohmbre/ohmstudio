CV {
    id: quantcv

    objectName: "QuantCV"

    property var choices
    onControlVoltsChanged: {
        controlVolts = Math.round(((controlVolts+10)/20)*choices.length)/choices.length*20-10
        engine.setControl(uuid(quantcv), controlVolts)
    }
    reading: stream

    stream: choices[
                Math.max(Math.min(Math.round(((controlVolts+10)/20)*choices.length),choices.length-1),0)
            ].toString()


}
