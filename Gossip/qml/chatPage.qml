import QtQuick 2.6
import QtQuick.Controls 2.1
import QtWebSockets 1.0

ApplicationWindow {
    id: window
    width: 540
    height: 960
    visible: true

    WebSocket {
        id: socket
        url: "ws://localhost:8080"
        onTextMessageReceived: {
            console.log("Message : "+message);
        }
        active: true
    }

    signal sendMessage(string message)

    function onmessage(message)
    {


    }

    Connections
    {
        target: window
        onSendMessage :
        {
            if(socket.status === WebSocket.Open)
            {
                console.log("Sending message : "+message);
                socket.sendTextMessage(message);
            }
            else
            {
                console.log("Server is not connected");
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: ContactPage {}
    }
}

