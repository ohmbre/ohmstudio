import QtQuick 2.12

CV {
    id: quantcv

    objectName: "QuantCV"

    property var choices: []
    property var choice: 0
    onChoiceChanged: { engine.setControl(uuid(quantcv), Math.round(choice)) }


    stream: `control(${uuid(quantcv)})`
    controller: PickController {}
    function toQML(indent) {
        return choice.toString();
    }
    onControlVoltsChanged: choice = controlVolts
    Component.onCompleted: {
        choiceChanged.connect(userChanges);
    }

}
