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

TrackQueueElement = require('./TrackQueueElement.coffee');
jstd = require('./jstd.js');

class TrackQueue

	constructor: (@app) ->
		@tracks = []

	empty: () ->
		return (@tracks.length == 0)

	indexOf: (trackUri) ->
		i = 0
		while (i < @tracks.length)
			if (@tracks[i].getUri() == trackUri)
				return (i)
			i++
		return (-1)

	vote: (clientId, trackUri) ->
		if ((idx = @indexOf(trackUri)) != -1)
			return @tracks[idx].vote(clientId)
		elem = new TrackQueueElement(@app, trackUri)
		elem.vote(clientId)
		@tracks.push(elem);

	unvote: (clientId, trackUri) ->
		if ((idx = @indexOf(trackUri)) != -1)
			@tracks[idx].unvote(clientId)
			if (@tracks[idx].getNbVotes() == 0)
				@tracks.splice(idx, 1);


	getNext: () ->
		@tracks.sort((a, b) -> a.getNbVotes() - b.getNbVotes())
		return (@track.pop())

	getQueue: () ->
		queue = []
		@_sort()
		for elem in @tracks
			data = {};
			data.nbVotes = elem.getNbVotes()
			data.uri = elem.getUri();
			data.track = elem.trackData;
			queue.push(data);
		return (queue)

	pop: () ->
		@_sort()
		elem = @tracks[0];
		@tracks.splice(0, 1)
		return (elem)


	_sort: () ->
		@tracks.sort((a, b) -> b.getNbVotes() - a.getNbVotes())

	getVotes: (clientId) ->
		res = []
		for elem in @tracks
			if (elem.hasVote(clientId))
				res.push(elem.getUri())
		return res

module.exports = TrackQueue;