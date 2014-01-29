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

class RoomSearchController
	constructor: (@$scope, @room, @locationManager, $routeParams, @$timeout) ->
		@room.enter($routeParams.room).catch () =>
			@locationManager.goTo('/roomSelect');
		@$scope.searchInput = "";
		@$scope.searchResults = null;
		@$scope.onInputChange = @onInputChange;
		@$scope.onTryThisClick = @onTryThisClick
		@$scope.trackClick = @onTrackClick;
		@$scope.onImgVisible = @onImgVisible;
		@timer = null;

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

RoomSearchController.$inject = ['$scope', 'room', 'locationManager', '$routeParams', '$timeout'];