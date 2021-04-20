import QtQuick 2.15

CV {
    id: quantcv
    property var choices: []
    controller: OhmChoiceBox {
        lineHeight: 7
        label: quantcv.label
        choice: quantcv.choices[volts]
        model: quantcv.choices
        onChosen: (newChoice) => {
            quantcv.volts = quantcv.choices.indexOf(newChoice)
        }
    }
}

