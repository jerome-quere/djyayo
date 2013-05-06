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

class User extends EventEmitter

	constructor: (@webService) ->
		super;
		@id = -1;
		@votes = [];
		@refresh();

	refresh: () =>
		@webService.query('me').then (httpRes) =>
			@id = httpRes.data.id;
			@votes = httpRes.data.votes;

	vote: (uri) ->
		@webService.query('vote', {uri: uri}).then (httpRes) =>
			@_addVote(uri)
			@emitEvent('queueChanged', [httpRes.data]);

	unvote: (uri) ->
		@webService.query('unvote', {uri: uri}).then (httpRes) =>
			@_delVote(uri)
			@emitEvent('queueChanged', [httpRes.data]);

	updateFromTrackQueue: (queue) =>
		@votes = [];
		for track in queue
			for user in track.votes
				if user.id == @id
					@votes.push(track.uri)

	haveMyVote: (uri) ->
		return @votes.indexOf(uri) != -1;

	_addVote: (uri) ->
		if (@votes.indexOf(uri) == -1)
			@votes.push(uri);

	_delVote: (uri) ->
		idx = @votes.indexOf(uri);
		if (idx != -1)
			@votes.splice(idx, 1);