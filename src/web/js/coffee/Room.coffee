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

class Room extends EventEmitter
	constructor: (@webService, @user) ->
		@user.on('logout', @exit);
		@_clear()

	getName: () -> @name
	isAdmin: () -> @admin;

	_clear: () ->
		@name = null;
		@player = false;
		@trackQueue = [];
		@currentTrack = null;
		@admin = false;

	enter: (name) =>
		if (@name != name)
			@name = name
			@emit('enter');
		return @refreshTrackQueue();

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


	getTrackQueue: () -> @trackQueue;
	havePlayer: () -> @player
	getCurrentTrack: () -> @currentTrack
	getName: () -> @name


	buildTrackQueue: (roomData) ->
		res = []
		for elem in roomData.queue
			data = {};
			data.track = elem.track;
			data.votes = elem.votes;
			data.haveMyVote = false;
			data.addedBy = elem.addedBy;
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
		data.addedBy = roomData.currentTrack.addedBy;
		return data;

	buildPlayer: (roomData) -> roomData.players.length != 0;

	refreshTrackQueue: () ->
		p = @webService.query("room/#{@name}");
		return p.then (data) =>
			@player = @buildPlayer(data);
			@trackQueue = @buildTrackQueue(data);
			@currentTrack = @buildCurrentTrack(data);
			@admin = data.admin;
			@emit('change');

	buildSearchResult: (searchResults) ->
		res = {tracks:[]};
		for track in searchResults.tracks
			data = track;
			if (!track.imgUrl?) then data.imgUrl = "images/album.png";
			data.nbVotes = 0;
			data.haveMyVote = @haveMyVote(track.uri);
			res.tracks.push(data);
		return res;


	vote: (uri) =>
		@webService.query("room/#{@name}/vote", {uri:uri}).then (data) =>
			@trackQueue = @buildTrackQueue(data);
			@emit('change');

	unvote: (uri) =>
		@webService.query("room/#{@name}/unvote", {uri:uri}).then (data) =>
			@trackQueue = @buildTrackQueue(data);
			@emit('change');

	search: (query) ->
		p = @webService.query("room/#{@name}/search", {query: query});
		return p.then (data) =>
			return @buildSearchResult(data)

	nextTrack: () -> @webService.query("room/#{@name}/nexttrack");
	deleteTrack: (uri) -> @webService.query("room/#{@name}/deletetrack", {uri: uri});