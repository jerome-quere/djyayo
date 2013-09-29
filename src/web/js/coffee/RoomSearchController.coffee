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

class RoomSearchController
	constructor: (@$scope, @room, $routeParams) ->
		@room.enter($routeParams.room)
		@$scope.searchInput = "";
		@$scope.searchResults = null;
		@$scope.search = @search;
		@$scope.vote = @vote;
		@$scope.unvote = @unvote;

	search: () =>
		if (@$scope.searchInput.length < 3)
			@$scope.searchResults = null
		query = @$scope.searchInput;
		p = @room.search(query);
		p.then (searchResults) =>
			if (query == @$scope.searchInput)
				@$scope.searchResults = searchResults;

	vote: (track) =>
		@room.vote(track.uri);
		track.haveMyVote = true;

	unvote: (track) =>
		track.haveMyVote = false;