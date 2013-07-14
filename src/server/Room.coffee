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

SpotifyCommunicator = require('./SpotifyCommunicator.coffee');
TrackQueue = require('./TrackQueue.coffee');

class Room
	constructor: (@name) ->
		@players = []
		@spotifyCom = new SpotifyCommunicator();
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;

	addPlayer: (player) ->
		@players.push(player);
		if (@players.length == 1)
			@players[0].on('endOfTrack', @onEndOfTrack);
			@playNextTrack()
		player.on('disconnect', () => @onPlayerDisconnect(player));

	onPlayerDisconnect: (player) ->
		idx = @players.indexOf(player);
		@players.splice(idx, 1);
		if (idx == 0 and @players.length)
			@players[0].on('endOfTrack', @onEndOfTrack);
		if (@players.length == 0)
			@currentTrack = null;
		else
			@playNextTrack()

	onEndOfTrack: () =>
		@playNextTrack()

	playNextTrack: () ->
		if (@currentTrack != null)
			@currentTrack = null;
		if (!@trackQueue.empty())
			@currentTrack = @trackQueue.pop();
			p.play(@currentTrack.getUri()) for p in @players;

	vote: (clientId, uri) ->
		@trackQueue.vote(clientId, uri);
	unvote: (clientId, uri) ->
		@trackQueue.unvote(clientId, uri)

	getData: () ->
		data = {}
		data.name = @name;
		data.players = for p in @players
			{id: p.getId()}
		data.queue = @trackQueue.getData()
		return data;

module.exports = Room