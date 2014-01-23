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

Config = require('./Config.coffee');
EventEmitter = require("events").EventEmitter
net = require('net');
SpotifyPlayer = require('./SpotifyPlayer.coffee');
IdGenerator = require('./IdGenerator.coffee');

class PlayerCommunicator extends EventEmitter

	constructor: () ->
		@idGenerator = new IdGenerator();
		@server = net.createServer(@onNewClient);
		@server.listen(Config.get('playerPort'));
		@server.on 'error', @onError;
		@players = [];


	onNewClient: (client) =>
		player = new SpotifyPlayer(@idGenerator.next(), client);
		player.on 'joinRoom', (roomName) =>
			console.log("ROOM NAME = #{roomName}");
			@emit 'joinRoom', player, roomName;
		player.on 'disconnect', () =>
			idx = @players.indexOf(player);
			if (idx != -1) then @players.splice(idx, 1);
		@players.push(player);
		console.log("Nbplayer: #{@players.length}")




	onError: (error) ->
		console.log(error);

module.exports = PlayerCommunicator;