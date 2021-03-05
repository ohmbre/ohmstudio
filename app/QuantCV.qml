import QtQuick 2.15

CV {
    id: quantcv
    property var choices: []
    controller: OhmChoiceBox {
        height: 6
        label: quantcv.label
        choice: quantcv.choices[volts]
        model: quantcv.choices
        onChosen: (newChoice) => {
            quantcv.volts = quantcv.choices.indexOf(newChoice)
        }
    }
}

