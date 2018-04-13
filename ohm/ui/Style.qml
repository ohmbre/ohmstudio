pragma Singleton
import QtQuick 2.10

QtObject {

    property var palette: {
        'light': 'E6EBE0',
        'medium': '9BC1BC',
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

    property color moduleColor: '#'+palette.dark
    property color moduleBorderColor: '#'+palette.light
    property color moduleLabelColor: '#'+paletteLit.light
    property int moduleBorderWidth: 2
    property real moduleLabelPadding: 6.5
    property real jackExtension: 10
    property color inJackColor: '#A0'+palette.dark
    property color inJackLitColor: '#FF'+paletteLit.dark
    property color outJackColor: '#A0'+palette.strong
    property color outJackLitColor: '#FF'+paletteLit.strong
    property real minJackGap: 0.1 // (radians)
    property real maxJackSweep: 1 // (radians)

    property color jackLabelColor: "#FF"+palette.light
    property real jackLabelGap: 2

    property color cableColor: '#'+palette.strong
    property double cableControlStiffness: 5
    property double cableGravity: 100

    property color buttonColor: '#'+palette.medium
    property color buttonOverColor: '#'+paletteLit.medium
    property color buttonBorderColor: '#'+paletteDim.medium
    property color buttonTextColor: '#'+paletteLit.light
    property color drawerColor: '#'+paletteLit.accent
    property color menuLitColor: '#'+paletteLit.medium
}
