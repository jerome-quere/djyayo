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

class User

	constructor: (@app) ->
		@id = -1;
		@votes = ko.observableArray();

	refresh: () =>
		@app.ws('me').then (data) =>
			@id = data.id;
			@votes(data.votes);

	vote: (uri) ->
		@app.ws('vote', {uri: uri}).then (data) =>
			@_addVote(uri)
			@app.updateQueue(data.queue);

	unvote: (uri) ->
		@app.ws('unvote', {uri: uri}).then (data) =>
			@_delVote(uri)
			@app.updateQueue(data.queue);

	haveVote: (uri) ->
		return @votes.indexOf(uri) != -1;

	_addVote: (uri) ->
		if (@votes.indexOf(uri))
			@votes.push(uri);

	_delVote: (uri) ->
		idx = @votes.indexOf(uri);
		if (idx != -1)
			@votes.splice(idx, 1);