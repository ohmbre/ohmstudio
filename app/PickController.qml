import QtQuick 2.13

OhmChoiceBox {
    id: pickController
    width: 110
    height: 16
    label.text: displayLabel
    control.currentIndex: choice
    choiceLabels: choices
    onChosen: choice = index
}
