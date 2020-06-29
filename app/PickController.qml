import QtQuick 2.15

OhmChoiceBox {
    id: pickController
    width: 110
    height: 16
    label: displayLabel
    choice: volts
    model: choices
    onChosen: function(newChoice) {
        volts = choices.indexOf(newChoice);
    }
}
