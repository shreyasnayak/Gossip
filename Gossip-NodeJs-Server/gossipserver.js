const sqlite3 = require("sqlite3").verbose();

/*Setup database*/

let db = new sqlite3.Database("./Messenger.db", err => {
  if (err) {
    return console.error(err.message);
  }
  console.log("Connected to the in-memory SQlite database");
  CreateTable();
});

var SocketMap = {};
const WebSocket = require("ws");
const wss = new WebSocket.Server({ ip: "localhost", port: 8080 });
var debugMode = true;
console.log("Running WebSocket server : ws://localhost:8080 ");

wss.on("connection", function connection(ws) {
  if (debugMode) console.log("New User connected");
  ws.on("message", function incoming(message) {
    var jsonMessage = JSON.parse(message);
    switch (jsonMessage["event"]) {
      case "register":
        register(ws, jsonMessage["payload"]);
        break;
      case "login":
        login(ws, jsonMessage["payload"]);
        break;
      case "send_message":
        deliverMessage(ws, jsonMessage["payload"]);
        break;
      case "retrieve_password":
        retrievePassword(ws, jsonMessage["payload"]);
        break;
      case "create_group":
        createGroup(ws, jsonMessage["payload"]);
        break;

      default:
        console.log("Unknown event, Message:", message);
        break;
    }
    if (debugMode) console.log("New request : ", message);
  });
  ws.on("close", function onClose(ws) {
    console.log("UserName", ws["username"], " Disconnected");
  });
});

function createGroup(ws, request) {
  /*TODO Create group and send responce */
  /*
	Request 
	
	"payload":{
		"group_name":"Grp_ABC",
		"user_names":["Shreyas","Rakesh"]
	}
	*/

  var response = {
    event: "create_group_status",
    payload: {
      status: true,
      group_name: request["group_name"],
      failure_reason: ""
    }
  };

  ws.send(JSON.stringify(response));
}
function CreateTable() {
  db.run(
    "CREATE TABLE User_data (Name varchar(20),Password varchar(20),Email varchar(30),Question varchar(100),Ans varchar(100))",
    err => {
      if (err) {
        return console.error(
          "Error while creating table User_data,Error Message:",
          err.message
        );
      }
      console.log("User_data TABLE created");
    }
  );
}

/*SignUp New user*/
function register(ws, request) {
  var response = {
    event: "register_status",
    payload: {
      register_status: false,
      username: request["username"],
      password: request["password"],
      failure_reason: "Already username exist"
    }
  };

  db.run(
    `INSERT INTO User_data(Name,Password,Email,Question,Ans) VALUES(?,?,?,?,?)`,
    [
      request["username"],
      request["password"],
      "",
      request["question"],
      request["answer"]
    ],
    function(err) {
      if (err) {
        console.log("Failed to add user,Error Message:" + err.message);
        return ws.send(JSON.stringify(response));
      } else {
        console.log("New user signup sucessfull");
        response["payload"]["register_status"] = true;
        response["payload"]["failure_reason"] = "";
        ws.send(JSON.stringify(response));
      }
    }
  );
}

/*Log User*/
function login(ws, request) {
  var response = {
    event: "login_status",
    response: {
      username: request["username"],
      login_status: false,
      failure_reason: ""
    }
  };
  var query =
    "SELECT Name,Password FROM User_data WHERE Name='" +
    request["username"] +
    "'"; //FixMe : Set query based on user
  console.log("Query : ", query);
  db.all(query, function(err, rows) {
    if (err) {
      response["response"]["login_status"] = false;
      response["response"]["failure_reason"] = "Sorry we have server problem";
      ws.send(JSON.stringify(response));
      console.log("Failed to Login, DataBase Error : " + err.message);
      return;
    }
    var sendStatus = false;
    rows.forEach(row => {
      if (sendStatus)
        return; /*Fetching the one row and exiting the async loop*/
      sendStatus = true;
      if (
        request["username"] === row.Name &&
        request["password"] === row.Password
      ) {
        /*Valid user password,Login accepted*/
        response["response"]["login_status"] = true;
        response["response"]["failure_reason"] = "";
        console.log("UserName :" + request["username"], " connected");
        SocketMap[request["username"]] = ws;
        ws["username"] = request["username"];
      } else {
        /*Invalid user password,Login rejected*/
        response["response"]["login_status"] = false;
        response["response"]["failure_reason"] = "Invalid credentials";
      }
    });

    if (sendStatus == false) {
      /*No data found in Database (Empty database or Empty row for query)*/
      response["response"]["login_status"] = false;
      response["response"]["failure_reason"] = "Invalid user";
    }
    ws.send(JSON.stringify(response));
  });

  /*Send list of Contact*/

  //TODO Send User List
  var response2 = {
    event: "load_contact",
    payload: {
      contact_list: ["m_abc", "m_efg"]
    }
  };
}

function retrievePassword(ws, request) {}

function deliverMessage(ws, request) {
  console.log("Send Message to :", request);
  if (SocketMap["ABC"]) {
    console.log("User ", request["to"], "is online message sent");
    var message = {
      event: "message",
      payload: request
    };
    var ws = SocketMap["ABC"];
    ws.send(JSON.stringify(message));
  } else {
    console.log("User ", request["to"], "is offline");
  }

  /*TODO If 'to' is for GroupName send it multiple users based on list*/
}

function setupDB(ws, request) {}
