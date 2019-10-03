import QtQuick 2.12

CV {
    id: quantcv
    property var choices: []
    property var choice: 0
    onChoiceChanged: { engine.setControl(uuid(quantcv), Math.round(choice)) }


    stream: `control(${uuid(quantcv)})`
    controller: PickController {}
    onControlVoltsChanged: choice = volts
    Component.onCompleted: {
        choiceChanged.connect(userChanges);
    }

}
