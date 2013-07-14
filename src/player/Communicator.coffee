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

Config = require('./Config.coffee');
Command = require('./Command.coffee');
EventEmitter = require('events').EventEmitter
io = require('socket.io-client');

class Communicator extends EventEmitter
	constructor: () ->
		@socket = null

	run: () ->
		@socket = io.connect(Config.get('host'), {port: Config.get('port')})
		@socket.on('connect', @onConnect)
		@socket.on('command', @onCommand)

	endOfTrack: () ->
		@socket.emit('command', new Command('endOfTrack'));

	onConnect: () =>
		console.log("Connected");
		@socket.emit("command", new Command("iamaplayer", {room:Config.get('room')}));

	onCommand: (command) => @emit('command', new Command(command.name, command.args))

module.exports = Communicator