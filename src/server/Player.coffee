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

Command = require("./Command.coffee")
EventEmitter = require("events").EventEmitter
HttpClient = require("./HttpClient.coffee");
When = require('when');

class Player extends EventEmitter
	constructor: (@id, @client) ->
		@client.on('end', @onDisconnect)
		@client.on('error', @onError)
		@client.on('data', @onData)
		@client.on('timeout', @onTimeout)
		@client.setEncoding('utf8')
		@client.setTimeout(45 * 1000)
		@buffer = ""
		@defers = []
		@client.write('hello\n')
		@timer = setInterval(@sendPing, 30 * 1000)

	onData: (chunk) =>
		@buffer = "#{@buffer}#{chunk}";
		while ((idx = @buffer.indexOf('\n')) != -1)
			cmd = @buffer.substr(0, idx)
			idx2 = cmd.indexOf(' ');
			if (idx2 == -1) then idx2 = cmd.length;
			[cmd, param] = [cmd.substr(0, idx2), cmd.substr(idx2 + 1)];
			@buffer = @buffer.substr(idx + 1);
			@onCommand(new Command(cmd, param));

	sendPing: () => @client.write('ping 4242\n');
	play: (uri) => @_pingPong(new Command('play', uri))
	getId: () -> @id

	onCommand: (command) =>
		if (command.getName() == "joinRoom")
			@emit('joinRoom', command.getArgs());
		else if (command.getName() == "endOfTrack")
			@emit('endOfTrack');
		else if (command.getName() == "pong")
			console.log("Get pong");
			#do Nothing
		else if (@defers.length != 0)
			defer = @defers.shift();
			if (command.getName() == 'success')
				defer.resolve(JSON.parse(command.getArgs()));
			else
				defer.reject(command.getArgs());

	onTimeout: () => @onDisconnect();
	onError: () => @onDisconnect();
	onDisconnect: () =>
		@client.end();
		clearInterval(@timer)
		@emit('disconnect')
		for defer in @defers
			defer.reject('player was disconnected');

	search: (query) => @_pingPong(new Command('search', query));
	lookup: (trackUri) => @_pingPong(new Command('lookup', trackUri));

	_pingPong: (cmd) =>
		defer = When.defer();
		@defers.push(defer);
		@client.write("#{cmd.getName()} #{cmd.getArgs()}\n");
		return defer.promise;

module.exports = Player