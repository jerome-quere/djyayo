##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDJ.
#
# SpotifyDJ is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDJ is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDJ.If not, see <http://www.gnu.org/licenses/>.
##

io = require('socket.io')
EventEmitter = require('events').EventEmitter
IdGenerator = require('./IdGenerator.coffee');
WebSocketClient = require('./WebSocketClient.coffee');

class WebSocketServer extends EventEmitter

	constructor: (httpServer) ->
		@io = io.listen(httpServer, {"log level":2});
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