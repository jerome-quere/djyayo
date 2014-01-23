##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDj.
#
# SpotifyDj is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDj is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDj.If not, see <http://www.gnu.org/licenses/>.
##

Command = require("./Command.coffee")
EventEmitter = require("events").EventEmitter
HttpClient = require("./HttpClient.coffee");
When = require('when');
Model = require('./Model.coffee');

class SpotifyPlayer extends EventEmitter
	constructor: (@id, @client) ->
		@client.on('end', @onDisconnect)
		@client.on('data', @onData)
		@client.setEncoding('utf8');
		@buffer = "";
		@timer = setInterval(@sendPing, 1000);
		@toDo = [];
		@client.write('hello\n')

	onData: (chunk) =>
		@buffer = "#{@buffer}#{chunk}";
		while ((idx = @buffer.indexOf('\n')) != -1)
			cmd = @buffer.substr(0, idx)
			idx2 = cmd.indexOf(' ');
			if (idx2 == -1) then idx2 = cmd.length;
			[cmd, param] = [cmd.substr(0, idx2), cmd.substr(idx2 + 1)];
			@buffer = @buffer.substr(idx + 1);
			@onCommand(new Command(cmd, param));

	sendPing: () =>
		@client.write('ping 300\n');


	play: (uri) =>
		@_pingPong(new Command('play', uri))

	getId: () -> @id

	onCommand: (command) =>
		if (command.getName() == "joinRoom")
			@emit('joinRoom', command.getArgs());
		else if (command.getName() == "pong")
			#doNothing
		else if (command.getName() == "endOfTrack")
			@emit('endOfTrack');
		else
			if (command.getName() == 'success')
				@toDo[0].defer.resolve(JSON.parse(command.getArgs()));
			else
				@toDo[0].defer.reject(command.getArgs());
			@toDo.shift();
			@_execToDo()

	onDisconnect: () =>
		clearInterval(@timer)
		@emit('disconnect')

	search: (query) =>
		@_pingPong(new Command('search', query)).then (res) =>
			return res;

	_execToDo: () =>
		if (@toDo.length == 0 ) then return;
		cmd = @toDo[0].cmd;
		@client.write("#{cmd.getName()} #{cmd.getArgs()}\n");

	_pingPong: (cmd) =>
		defer = When.defer();
		@toDo.push({cmd:cmd, defer:defer});
		if (@toDo.length == 1)
			@_execToDo();
		return defer.promise;

module.exports = SpotifyPlayer