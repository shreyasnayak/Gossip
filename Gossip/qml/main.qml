import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtWebSockets 1.0
import com.github.shreyasnayak.ChatDbModel 1.0
import "qrc:/js/backend.js" as Backend


ApplicationWindow {
    id: rootWindow
    visible: true
    width: 420
    height: 680
    title: qsTr("Gossip")

    property color backGroundColor : "#394454"
    property color mainAppColor: "#6fda9c"
    property color mainTextCOlor: "#f0f0f0"
    property color popupBackGroundColor: "#b44"
    property color popupTextCOlor: "#ffffff"
    property string username
    property ContactPage contactList: ContactPage {}
    property SqlContactModel myModel : SqlContactModel{}
    property SqlConversationModel canvModels: SqlConversationModel{}
    ListModel {
        id:aviContact
        ListElement {
            name: "Shreyas"
            checked: false
        }
        ListElement {
            name: "Rakesh"
            checked: false
        }
        ListElement {
            name: "Chethan"
            checked: false
        }
    }

    Timer {
        id: reconnect
        interval: 5000
        onTriggered:{
            console.log("Reconneting to server");
            socket.active=true;
        }
        repeat: false
    }

    WebSocket {
        id: socket
        url: "ws://localhost:8080"
        onTextMessageReceived:onmessage(message)
        active: true
        onStatusChanged:{
            if(status ==WebSocket.Closed)
            {
                console.log("Server disconnected");
                socket.active=false;
                reconnect.start();
            }
            else if(status==WebSocket.Open)
            {
                console.log("Connected to server");
            }
            else
            {}

        }

    }

    signal sendMessage(string message)
    function sendMessageToUser(messageText,to)
    {
        console.log("Trying to send message : ",messageText);

        var request={
            "event":"send_message",
            "payload":
            {
                "from":username,
                "to":to,
                "message":messageText
            }
        }
        sendMessage(JSON.stringify(request));
    }

    function onmessage(message)
    {
        console.log("Message from Node:",message)
        var jsonMessage=JSON.parse(message);
        switch (jsonMessage["event"])
        {
        case "login_status":
            if(jsonMessage["response"]["login_status"])
            {
                username=jsonMessage["response"]["username"];
                console.log("Login accepted,Username:"+jsonMessage["response"]["username"] )
                showUserInfo(jsonMessage["response"]["username"])
            }
            else
            {
                popup.popMessage = jsonMessage["response"]["failure_reason"];
                popup.open()
            }

            break;
        case "register_status":
            if(jsonMessage["payload"]["register_status"])
            {

                popup.popMessage = "Registration successful,Please Login";
                popup.open()
                stackView.pop()
            }
            else
            {
                popup.popMessage = jsonMessage["payload"]["failure_reason"];
                popup.open()
            }
            break;
        case "incoming_message" :
            var from = jsonMessage["payload"]["from"];
            var usermessage =jsonMessage["payload"]["message"];
            canvModels.recipient =from
            canvModels.sendMessage(from,"Me",usermessage);
            popup.popMessage = "New Message from "+from;
            popup.open()
            stackView.pop()

            break;
        case "create_group_status":
            if(jsonMessage["payload"]["status"])
            {
                myModel.addContact(jsonMessage["payload"]["group_name"]);
                popup.popMessage = "Group created";
                popup.open()
            }
            else
            {
                popup.popMessage = jsonMessage["payload"]["failure_reason"];
                popup.open()
            }

            break;

        case "load_contact":
                console.log("Loading contact");
                var contList=jsonMessage["payload"]["contact_list"];
                for(var i=0;i<contList.length;i++)
                {
                    console.log(contList[i]);
                }
            break;

        default : console.log("Unknown events");
        }
    }

    Connections
    {
        target: rootWindow
        onSendMessage :
        {
            if(socket.status === WebSocket.Open)
            {
                console.log("Sending message : "+message);
                socket.sendTextMessage(message);
            }
            else
            {
                popup.popMessage = "Server is not connected";
                popup.open()
                console.log("Server is not connected");
            }
        }
    }
    FontLoader {
        id: fontAwesome
        name: "fontawesome"
        source: "qrc:/font/fontawesome-webfont.ttf"
    }

    // Main stackview
    StackView{
        id: stackView
        focus: true
        anchors.fill: parent
    }

    // After loading show initial Login Page
    Component.onCompleted: {
        stackView.push("qrc:/qml/LogInPage.qml")   //initial page
    }

    //Popup to show messages or warnings on the bottom postion of the screen
    Popup {
        id: popup
        property alias popMessage: message.text

        background: Rectangle {
            implicitWidth: rootWindow.width
            implicitHeight: 60
            color: popupBackGroundColor
        }
        y: (rootWindow.height - 60)
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        Text {
            id: message
            anchors.centerIn: parent
            font.pointSize: 12
            color: popupTextCOlor
        }
        onOpened: popupClose.start()
    }

    // Popup will be closed automatically in 2 seconds after its opened
    Timer {
        id: popupClose
        interval: 2000
        onTriggered: popup.close()
    }

    // Register New user
    function registerNewUser(uname, pword, pword2,qut,ans)
    {
        //Check Server Status
        if(socket.status != WebSocket.Open)
        {
            popup.popMessage = "Server not connected";
            popup.open()
            return
        }

        var ret  = Backend.validateRegisterCredentials(uname, pword, pword2, qut,ans)
        var message = ""
        switch(ret)
        {
        case 0: message = "Valid details!"
            break;
        case 1: message = "Missing credentials!"
            break;
        case 2: message = "Password does not match!"
            break;
        }

        if(0 !== ret)
        {
            popup.popMessage = message
            popup.open()
            return
        }

        //Send login request to server
        var request={
            "event": "register",
            "payload": {
                "username": uname,
                "password": pword,
                "question":qut,
                "answer":ans
            }
        }
        sendMessage(JSON.stringify(request));
    }

    // Login users
    function loginUser(uname, pword)
    {
        //Check Server Status
        if(socket.status != WebSocket.Open)
        {
            popup.popMessage = "Server not connected";
            popup.open()
            return
        }

        var ret  = Backend.validateUserCredentials(uname, pword)
        var message = ""
        if(ret)
        {
            message = "Missing credentials!"
            popup.popMessage = message
            popup.open()
            return
        }

        //Send login request to server
        var request={
            "event": "login",
            "payload": {
                "username": uname,
                "password": pword
            }
        }
        sendMessage(JSON.stringify(request));
    }

    // Retrieve password using phoneNumber
    function retrievePassword(uname, phoneNumber)
    {


        var ret  = Backend.validateUserCredentials(uname, phint)
        var message = ""
        var pword = ""
        if(ret)
        {
            message = "Missing credentials!"
            popup.popMessage = message
            popup.open()
            return ""
        }

        var request={
            "event":""
        }

        return ""
    }


    // Show UserInfo page
    function showUserInfo(uname)
    {
        stackView.replace("qrc:/qml/UserInfoPage.qml", {"userName": uname})
    }

    // Logout and show login page
    function logoutSession()
    {
        stackView.replace("qrc:/qml/LogInPage.qml")
    }

    // Show Password reset page
    function forgotPassword()
    {
        stackView.replace("qrc:/qml/PasswordResetPage.qml")
    }

    // Show all users
    function showAllUsers()
    {
        dataBase.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM UserDetails');
            var data = ""
            for(var i = 0; i < rs.rows.length; i++) {
                data += rs.rows.item(i).username + "\n"
            }
            console.log(data)
        })

    }
}
