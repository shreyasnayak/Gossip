
import QtQuick 2.6
import QtQuick.Controls 2.1
import com.github.shreyasnayak.ChatDbModel 1.0
import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

Page {

    id: root
    header: ChatToolBar {
        Label {
            text: qsTr("Contacts")
            font.pixelSize: 20
            anchors.centerIn: parent
        }
        ToolButton {
            text: qsTr("‹")
            onClicked: addContact.open();
        }
    }
    Dialog {
        id: addContact
        standardButtons: StandardButton.Ok | StandardButton.Cancel

        GroupBox{
            Material.accent: Material.LightBlue
            title: qsTr("Contact Profile")


            ColumnLayout{

                ComboBox {
                    id:selection
                    width: 200
                    model: [ "Add Contact", "Create Group"]
                    onActivated: {
                        username.visible =false;
                        groupName.visible =false;
                        selCont.visible =false;
                        switch (index)
                        {
                        case 0: username.visible =true;
                            break;
                        case 1: groupName.visible =true;
                            selCont.visible =true;
                            break;
                        case 2: groupName.visible =true;
                            selCont.visible =true;
                            break;
                        }
                    }

                }

                GridLayout{
                    id :username
                    columns: 2
                    Label{
                        text: qsTr("User Name :")
                    }
                    TextField{
                        id: usernameText
                    }
                }

                GridLayout{
                    id :groupName
                    visible: false
                    columns: 2

                    Label{
                        text: qsTr("Group Name:     ")
                    }
                    TextField{
                        id: groupNameText
                    }
                }
                GridLayout{
                    id :selCont
                    columns: 2
                    visible: false
                    Label{
                        text: qsTr("Select Contact: ")
                    }
                    ComboBox {
                        id:selContact
                        width: 200
                        model: aviContact
                        delegate: Item {
                            width: parent.width
                            implicitHeight: checkDelegate.implicitHeight
                            CheckDelegate {
                                id: checkDelegate
                                width: parent.width
                                height: parent.height
                                text: model.name
                                highlighted: selContact.highlightedIndex === index
                                checked: model.checked
                                onCheckedChanged: model.checked = checked
                            }
                        }
                    }
                }
            }
        }
        onAccepted: {
            switch(selection.currentIndex)
            {
            case 0: console.log("Adding contact");
                myModel.addContact(usernameText.text);
                break;
            case 1: console.log("Createing group");

                var myList=[];
                for(var i=0;i<aviContact.count;i++)
                {
                    if(aviContact.get(i).checked)
                    {
                        myList.push(aviContact.get(i).name)
                    }
                }

                var request={
                    "event":"create_group",
                    "payload":
                    {
                        "group_name":groupNameText.text,
                        "user_names":myList
                    }
                }
                sendMessage(JSON.stringify(request));
                break;


            }
        }

    }
    ListView {
        id: listView
        anchors.fill: parent
        topMargin: 10
        leftMargin: 10
        bottomMargin: 10
        rightMargin: 10
        spacing: 20
        model: myModel
        delegate: ItemDelegate {
            text: model.display
            width: listView.width - listView.leftMargin - listView.rightMargin
            height: 40
            onClicked: root.StackView.view.push("qrc:/qml/ConversationPage.qml", { inConversationWith: model.display })
        }
    }
}

