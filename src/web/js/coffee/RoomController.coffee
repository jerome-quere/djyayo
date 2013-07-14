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

class RoomController

	constructor: (@$scope, $routeParams, @$location, @webService, @spotify, @user, $timeout) ->
		@roomName = $routeParams.room;
		@$scope.onTrackClick = @onTrackClick;
		@refresh();

	onSearchBtnClick: () ->
		@searchPanel.show();

	onTrackClick: (e) =>
		if (!e?) then return;
		uri = e.uri;
		if (e.haveMyVote)
			@unvote(uri)
		else
			@vote(uri);

	buildPlayer: (roomData) -> roomData.players.length != 0;

	buildTrackQueue: (roomData) ->
		res = []
		for elem in roomData.queue
			data = {};
			data.uri = elem.uri;
			data.trackName =  if (elem.track) then elem.track.name else '...' ;
			data.artistName = if (elem.track) then elem.track.artists[0].name else '...';
			data.albumImg = if (elem.track) then Model.getAlbumImg(elem.track.album.uri) else Model.getAlbumImg(null);
			data.nbVotes = elem.nbVotes;
			data.haveMyVote = @user.getId() in elem.votes;
			res.push(data);
		return res;

	buildCurrentTrack: (roomData) ->
		if (!roomData.currentTrack)
			return null;
		track = roomData.currentTrack
		res.uri = track.uri;
		res.trackName =	 if (track.track) then track.track.name else '...' ;
		res.artistName = if (track.track) then track.track.artists[0].name else '...';
		res.albumImg = if (track.track) then Model.getAlbumImg(track.track.album.uri) else Model.getAlbumImg(null);
		return res;

	refresh: () =>
		p = @webService.query("room/#{@roomName}");
		p.then (data) =>
			@$scope.player = @buildPlayer(data);
			@$scope.trackQueue = @buildTrackQueue(data);
			@$scope.currentTrack = @buildCurrentTrack(data);
		p.then null, () =>
			@$location.path('/roomSelect');