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

class Room extends EventEmitter
	constructor: (@webService, @model, @user) ->
		@user.on('logout', @exit);
		@_clear()

	getName: () -> @name

	_clear: () ->
		@name = null;
		@player = null;
		@trackQueue = null;
		@currentTrack = null;

	enter: (@name) =>
		@emit('enter');
		return @refreshTrackQueue()

	exit: () =>
		@_clear();
		@emit('exit')

	haveMyVote: (uri) =>
		for elem in @trackQueue
			if elem.track.uri == uri
				for vote in elem.votes
					if (vote.id == @user.getId())
						return true;
		return false;

	buildTrackQueue: (roomData) ->
		res = []
		for elem in roomData.queue
			data = {};
			data.track = elem.track;
			data.votes = elem.votes;
			data.haveMyVote = false;
			for user in elem.votes
				if (@user.getId() == user.id)
					data.haveMyVote = true;
					break;
			res.push(data);
		return res;

	buildCurrentTrack: (roomData) ->
		if (!roomData.currentTrack)
			return null;
		data = {};
		data.track = roomData.currentTrack.track;
		data.votes = roomData.currentTrack.votes;
		return data;

	buildPlayer: (roomData) -> roomData.players.length != 0;

	refreshTrackQueue: () ->
		p = @webService.query("room/#{@name}");
		return p.then (data) =>
			@player = @buildPlayer(data);
			@trackQueue = @buildTrackQueue(data);
			@currentTrack = @buildCurrentTrack(data);

	buildSearchResult: (searchResults) ->
		res = {tracks:[]};
		for track in searchResults.tracks
			data = track;
			track.album.imgUrl = "images/album.png";
			do (track) =>
				@model.getAlbumImg(data.album.uri).then (url) ->
					track.album.imgUrl = url;
			data.nbVotes = 0;
			data.haveMyVote = @haveMyVote(track.uri);
			res.tracks.push(data);
		return res;


	vote: (uri) =>
		@webService.query("room/#{@name}/vote", {uri:uri}).then (data) =>
			@trackQueue = @buildTrackQueue(data);

	unvote: (uri) =>
		@webService.query("room/#{@name}/unvote", {uri:uri}).then (data) =>
			@trackQueue = @buildTrackQueue(data);

	search: (query) ->
		p = @webService.query("room/#{@name}/search", {query: query});
		return p.then (data) =>
			return @buildSearchResult(data.results)