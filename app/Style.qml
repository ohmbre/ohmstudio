pragma Singleton
import QtQuick 2.11

QtObject {

    property var palette: {
        'light': '#F1F1F1',
        'medium': '#DAD7CD',
        'dark': '#878E88',
        'accent': '#619CAB',
        'strong': '#F55D3E',
    }


    property color patchBackgroundColor: 'black'

    property color moduleColor: palette.accent
    property color moduleBorderColor: 'white'
    property color moduleLabelColor: 'white'
    property double moduleBorderWidth: 2.2
    property real moduleLabelPadding: 6.5
    property real jackExtension: 10
    property color inJackColor: '#70A87C'
    property color inJackLitColor: Qt.lighter(inJackColor)
    property color outJackColor: '#BC4E51'
    property color outJackLitColor: Qt.lighter(outJackColor)
    property real maxJackSweep: 10

    property color jackLabelColor: 'white'
    property real jackLabelGap: 3
    property real jackTabRadius: 12

    property color cableColor: palette.strong
    property double cableGravity: 100

    property color buttonColor: palette.accent
    property color buttonOverColor: Qt.lighter(buttonColor)
    property color buttonBorderColor: Qt.darker(buttonColor,1.4)
    property color buttonTextColor: palette.light
    property color drawerColor: palette.medium
    property color menuLitColor: palette.medium
    property color fileChooseBgColor: palette.accent
    property color fileChooseLitColor: palette.strong
    property color fileChooseTextColor: 'white'

    property color sliderColor: palette.medium
    property color sliderLitColor: palette.dark
    property color sliderHandleColor: palette.light
    property color sliderHandleLitColor: Qt.lighter(sliderHandleColor)

    property color darkText: palette.dark
}
