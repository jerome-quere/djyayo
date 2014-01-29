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

Command = require('./Command.coffee');
TrackQueue = require('./TrackQueue.coffee');

class Room
	constructor: (@name) ->
		@players = []
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;
		@clients = [];

	addPlayer: (player) ->
		@players.push(player);
		if (@players.length == 1)
			@players[0].on('endOfTrack', @onEndOfTrack);
			@playNextTrack()
		player.on('disconnect', () => @onPlayerDisconnect(player));
		@changed();


	addClient: (client) ->
		@clients.push(client);

	delClient: (client) ->
		if ((idx == @client.indexOf(client)) != -1)
			@players.splice(idx, 1);

	onPlayerDisconnect: (player) ->
		idx = @players.indexOf(player);
		@players.splice(idx, 1);
		if (idx == 0 and @players.length)
			@players[0].on('endOfTrack', @onEndOfTrack);
		if (@players.length == 0)
			@currentTrack = null;
		else
			@playNextTrack()
		@changed();

	onEndOfTrack: () =>
		@playNextTrack()

	playNextTrack: () ->
		@currentTrack = null;
		if (!@trackQueue.empty())
			@currentTrack = @trackQueue.pop();
			p.play(@currentTrack.getUri()) for p in @players;
		@changed();

	vote: (clientId, trackUri) ->
		if (!@players.length)
			throw "No player connected"
		@players[0].lookup(trackUri).then (track) =>
			@trackQueue.vote(clientId, track);
			if (@currentTrack == null and @players.length != 0)
				@playNextTrack();
			@changed();

	unvote: (clientId, uri) ->
		@trackQueue.unvote(clientId, uri)
		@changed();

	search: (query) =>
		@players[0].search(query).then (data) =>
			return data;


	changed: () =>
		for client in @clients
			client.send(new Command('roomChanged'));

	getData: () ->
		data = {}
		data.name = @name;
		if (@currentTrack?) then data.currentTrack = @currentTrack.getData();
		data.players = for p in @players
			{id: p.getId()}
		data.queue = @trackQueue.getData()
		return data;

module.exports = Room