import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import "qrc:/js/backend.js" as Backend

Page {
    id: userInfoPage

    property string userName: ""

    background: Rectangle {
        color: backGroundColor
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: contactList
    }

}
