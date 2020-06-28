import QtQuick 2.15

OhmChoiceBox {
    id: pickController
    width: 110
    height: 16
    label.text: displayLabel
    control.currentIndex: volts
    choiceLabels: choices
    onChosen: volts = index
}
