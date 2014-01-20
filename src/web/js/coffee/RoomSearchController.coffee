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
	constructor: (@$scope, @room, @model, $routeParams, @$timeout) ->
		@room.enter($routeParams.room)
		@$scope.searchInput = "";
		@$scope.searchResults = null;
		@$scope.onInputChange = @onInputChange;
		@$scope.onTryThisClick = @onTryThisClick
		@$scope.trackClick = @onTrackClick;
		@$scope.onImgVisible = @onImgVisible;
		@timer = null;

	onImgVisible: (track) =>
		@model.getAlbumImg(track.album.uri).then (url) ->
			track.album.imgUrl = url;


	onInputChange: () =>
		value = @$scope.searchInput;
		if (@timer?)
			@$timeout.cancel(@timer)
			@timer = null;
		@timer = @$timeout(@search, 500);

	search: () =>
		query = @$scope.searchInput;
		@$scope.searchResults = null;
		p = @room.search(query);
		p.then (searchResults) =>
			if (query == @$scope.searchInput)
				@$scope.searchResults = searchResults;

	onTrackClick: (track) =>
		if (track.haveMyVote)
			@room.unvote(track.uri);
			track.haveMyVote = false;
		else
			@room.vote(track.uri);
			track.haveMyVote = true;

	onTryThisClick: () =>
		@$scope.searchInput = "Selena Gomez";
		@onInputChange();
		return false;

RoomSearchController.$inject = ['$scope', 'room', 'model', '$routeParams', '$timeout'];