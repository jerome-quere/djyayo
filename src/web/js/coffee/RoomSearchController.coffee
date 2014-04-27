##
# The MIT License (MIT)
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
	constructor: (@$scope, @room, @locationManager, $routeParams, @$timeout, @loading) ->
		@room.enter($routeParams.room).catch () =>
			@locationManager.goTo('/roomSelect');

		@room.on 'change', @$scope, @onRoomChange
		@onRoomChange()

		@timer			= null;

		@$scope.searchInput	= "";
		@$scope.searchResults	= null;
		@$scope.loading		= false;
		@$scope.onInputChange	= @onInputChange;
		@$scope.onTryThisClick	= @onTryThisClick
		@$scope.trackClick	= @onTrackClick;

	onRoomChange: () => @$scope.havePlayer = @room.havePlayer();

	onInputChange: () =>
		value = @$scope.searchInput;
		if (@timer?)
			@$timeout.cancel(@timer)
			@timer = null;
		if value then @timer = @$timeout(@search, 500);

	_startLoading: () =>
		@loading.start();
		@$scope.loading = true;

	_doneLoading: () =>
		@loading.done();
		@$scope.loading = false;

	search: () =>
		query = @$scope.searchInput;
		@$scope.searchResults = null;
		@_startLoading();
		p = @room.search(query).then (searchResults) =>
			if (query == @$scope.searchInput)
				@$scope.searchResults = searchResults.tracks;
				@_doneLoading();

	onTrackClick: (track) =>
		if track.haveMyVote then @room.unvote(track.uri) else @room.vote(track.uri);
		track.haveMyVote = !track.haveMyVote

	onTryThisClick: () =>
		@$scope.searchInput = "Selena Gomez";
		@onInputChange();
		return false;

RoomSearchController.$inject = ['$scope', 'room', 'locationManager', '$routeParams', '$timeout', 'loading'];
