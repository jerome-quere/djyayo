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

SpotifyCommandFactory = require("./SpotifyCommandFactory.coffee");


class TrackQueueElement

	constructor: (@track) ->
		@clients = []

	vote: (clientId) ->
		if (@clients.indexOf(clientId) == -1)
			@clients.push(clientId)

	unvote: (clientId) =>
		if ((idx = @clients.indexOf(clientId)) != -1)
			@clients.splice(idx, 1);

	getUri: () -> @track.uri

	getNbVotes: () -> @clients.length

	getVotes: () ->
		res = []
		for id in @clients
			res.push({id:id});
		return res

	hasVote: (clientId) ->
		return @clients.indexOf(clientId) != -1

	getData: () -> {votes: @getVotes(), track: @track}

module.exports = TrackQueueElement;