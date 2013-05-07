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

net = require('net');
SpotifyClientBuffer = require('./SpotifyClientBuffer.coffee');
EventEmitter = require('events').EventEmitter

class SpotifyServer extends EventEmitter
	constructor: (@port) ->
		@server = net.createServer({}, @onNewClient);
		@client = null;
		@buffer = new SpotifyClientBuffer();
		@buffer.on('command', @onCommandReady);

	send: (command) ->
		if (@client?)
			@client.write(command)

	onClientRead: (data) =>
		@buffer.append(data);

	onClientEnd: (data) =>
		@client =  null;
		@buffer.clear();
		@emit('disconnection');

	onCommandReady: (cmd) =>
		@emit('commandReceived', cmd);

	onNewClient: (@client) =>
		@client.on('data', @onClientRead);
		@client.on('end', @onClientEnd);
		@buffer.clear();
		@emit('connection')

	isConnected: () => @client?

	run: () => @server.listen(@port);

module.exports = SpotifyServer