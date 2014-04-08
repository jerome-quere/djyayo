##
#The MIT License (MIT)
#
# Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##

io = require('socket.io')
EventEmitter = require('events').EventEmitter
IdGenerator = require('./IdGenerator.coffee');
WebSocketClient = require('./WebSocketClient.coffee');

class WebSocketServer extends EventEmitter

	constructor: (httpServer) ->
		@io = io.listen(httpServer, {"log level":1});
		@io.on('connection', @onConnection);
		@idGenerator = new IdGenerator();
		@clients = {};

	onConnection: (socket) =>
		id = @idGenerator.next();
		client = new WebSocketClient(id, socket)
		@clients[id] = client;
		client.on('disconnect', () => @onDisconnect(client))
		client.on('cmd', (data) => @onCommand(client, data))
		@emit('connect', client)

	onCommand: (client, data) =>
		@emit('cmd', client, data)

	onDisconnect: (client) =>
		delete @clients[client.getId()]
		@emit('disconnect', client);

	broadcast: (command) ->
		for id, client of @clients
			client.send(command)
			console.log("I SEND", command, " to ", client.getId());


module.exports = WebSocketServer;