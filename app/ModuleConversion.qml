import QtQuick 2.14
import QtQuick.Controls 2.14

Item {
    TabBar {
        id: tabBar
        x: 0
        y: 0
        width: 251
        height: 600

        TabButton {

            text: "patch"
        }

        TabButton {
            text: "settings"
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:800}
}
##^##*/
