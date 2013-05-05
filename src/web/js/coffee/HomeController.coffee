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

class HomeController

	constructor: ($scope, @trackQueue, @spotify, @user) ->
		@scope = $scope;
		@scope.trackQueue = @trackQueue;
		@scope.spotify = @spotify
		@scope.onTrackClick = @onTrackClick;

	onSearchBtnClick: () ->
		@searchPanel.show();

	onTrackClick: (e) =>
		if (!e?) then return;
		uri = e.uri;
		console.log(e);
		if (e.haveMyVote)
			@user.unvote(uri)
		else
			@user.vote(uri);

	buildQueue: () ->
		res = []
		for elem in @app.getQueue()
			data = {};
			data.uri = elem.uri;
			data.trackName =  if (elem.track?) then elem.track.name else '...' ;
			data.artistName = if (elem.track?) then elem.track.artists[0].name else '...';
			data.albumImg = if (elem.track?) then Model.getAlbumImg(elem.track.album.uri) else Model.getAlbumImg(null);
			data.nbVotes = elem.nbVotes;
			func = () =>
				uri = data.uri
				() => @app.getUser().haveVote(uri)
			func = func();
			data.haveMyVote = ko.computed(func);
			res.push(data);
		return res;