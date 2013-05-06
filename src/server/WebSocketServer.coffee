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
IdGenerator = require('./IdGenerator.coffee');
WebSocketClient = require('./WebSocketClient.coffee');

class WebSocketServer

	constructor: (httpServer) ->
		@io = io.listen(httpServer);
		@io.on('connection', @onConnection);
		@idGenerator = new IdGenerator();
		@clients = [];

	onConnection: (socket) =>
		id = @idGenerator.next();
		client = new WebSocketClient(id, socket)
		@clients.push(client);
		socket.on('disconnect', () => @onDisconnect(id))

	onDisconnect: (id) =>
		console.log("Disconnect")
		i = 0;
		while (i < @clients.length)
			if (@clients[i].getId() == id)
				@clients.splice(id, 1);
				break;
			i++

	broadcast: (eventName) =>
		for client in @clients
			client.send(eventName)


module.exports = WebSocketServer;