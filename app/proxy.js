/*
   Proxies connections to IQFeed.
   Holds connection to IQFeed to prevent it from shutting down.
*/
var
	net = require('net'),
	fs = require('fs');

var portMap = {
	5009: 5010,
	9100: 9101,
	9300: 9301
};

var config = {
	appName: process.env.APP_NAME || "MATLAB_1694",
	appVersion: process.env.APP_VERSION || "1.0",
	login: process.env.LOGIN,
	password: process.env.PASSWORD
};

Object.keys(portMap).forEach(function(port) {
	net.createServer(function(socket) {
		var beforeConnectedBuffer = "";
		var connected = false;
		var connection = net.createConnection(port);
		socket.on('close', function() {
			connection.destroy();
		});
		socket.on('error', function(err) {
			console.error(err);
		});
		socket.on('data', function(data) {
			if (connected) {
				connection.write(data);
			} else {
				beforeConnectedBuffer += data.toString();
			}
		});
		connection.on('connect', function() {
			connected = true;
			connection.write(beforeConnectedBuffer);
		});
		connection.on('error', function(err) {
			console.error(err);
			connection.unpipe(socket);
			connection.destroy();
			socket.end();
		});
		connection.pipe(socket);
	}).listen(portMap[port]);
});

/*
We need to connect IQFeed to servers by passing 'connect' command to it.
*/
function startIqFeed() {
	var port = 9300; // IQFeed admin port

	console.log("Connecting to port ", port);

	var socket = net.createConnection(port);
	socket.on('error', function(err) {
	});
	socket.on('close', function() {
		console.log("Disconnected. Reconnecting in 1 second.");
		setTimeout(startIqFeed, 1000);
	});
	socket.on('connect', function() {
		console.log("Connected.");
		socket.write([
			"S,REGISTER CLIENT APP," + config.appName + "," + config.appVersion,
			"S,SET LOGINID," + config.login,
			"S,SET PASSWORD," + config.password,
			"S,CONNECT"
		].join("\r\n")+"\r\n");
	});
	socket.on('data', function(data) {
		if (data && data.toString().match(/S,STATS.*Not Connected/)) {
                    console.log("Sending 'connect' command.");
                    socket.write("S,CONNECT\r\n");
                }
		console.log(data.toString ? data.toString().replace(/[\r\n]+/, '') : data);
	});
}
startIqFeed();
