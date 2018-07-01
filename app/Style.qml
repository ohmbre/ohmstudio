pragma Singleton
import QtQuick 2.11

QtObject {

    property var palette: {
        'light': 'E6EBE0',
        'medium': '9BC1BC',
        'gray': 'CCCCCC',
        'dark': '54969A',
        'accent': 'F4F1BB',
        'strong': 'ED6A5A',
    }

    property var paletteDim: {
        'light' : 'D2D6CC',
        'medium': '88B0AB',
        'dark': '4C878B',
        'accent': 'DEDCAA',
        'strong': 'D86152',
    }

    property var paletteLit: {
        'light' : 'FCFDFC',
        'medium': 'ADCCC8',
        'dark': '5CA4A9',
        'accent': 'F7F4CD',
        'strong': 'F08578',
    }


    property color patchBackgroundColor: "black"

    property color moduleColor: '#5E99AA'
    property color moduleBorderColor: '#'+palette.light
    property color moduleLabelColor: '#'+paletteLit.light
    property double moduleBorderWidth: 2.2
    property real moduleLabelPadding: 6.5
    property real jackExtension: 10
    property color inJackColor: '#70A87C'
    property color inJackLitColor: Qt.lighter(inJackColor)
    property color outJackColor: '#BC4E51'
    property color outJackLitColor: Qt.lighter(outJackColor)
    property real maxJackSweep: 10

    property color jackLabelColor: "#FF"+palette.light
    property real jackLabelGap: 3
    property real jackTabRadius: 12

    property color cableColor: '#'+palette.strong
    property double cableControlStiffness: 5
    property double cableGravity: 100

    property color buttonColor: '#'+palette.medium
    property color buttonOverColor: '#'+paletteLit.medium
    property color buttonBorderColor: '#'+paletteDim.medium
    property color buttonTextColor: '#'+paletteLit.light
    property color drawerColor: '#'+paletteLit.accent
    property color menuLitColor: '#'+paletteLit.medium
    property color fileChooseBgColor: '#'+palette.medium
    property color fileChooseLitColor: '#'+paletteLit.strong
    property color fileChooseTextColor: '#'+paletteLit.light

    property color sliderColor: '#'+palette.gray
    property color sliderLitColor: '#'+palette.dark
    property color sliderHandleColor: '#'+paletteDim.dark
    property color sliderHandleLitColor: '#'+paletteLit.dark

    property color darkText: '#536b65'
}
