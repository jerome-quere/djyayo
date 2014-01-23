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

Command = require('./Command.coffee');
TrackQueue = require('./TrackQueue.coffee');

class Room
	constructor: (@name) ->
		@players = []
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;
		@clients = [];

	addPlayer: (player) ->
		console.log("APPLICATION GET ROOMNAME #{@name}");
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

	vote: (clientId, track) ->
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