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

class RoomServiceController extends EventEmitter
	constructor: (@webService, @user) ->
		@user.on('logout', @exit);
		@_clear()

	isAdmin:	() -> @admin
	getTrackQueue:	() -> @trackQueue
	havePlayer:	() -> @player
	getCurrentTrack:() -> @currentTrack
	getName:	() -> @name

	_clear: () ->
		@name		= null;
		@player		= false;
		@trackQueue	= new MyArray([]);
		@currentTrack	= null;
		@admin		= false;

	enter: (name) =>
		if (@name != name)
			@name = name
			@emit('enter');
		return @refreshTrackQueue();

	exit: () =>
		@_clear()
		@emit('exit')

	haveMyVote: (uri) =>
		e = new MyArray(@trackQueue).find (e) -> e.track.uri == uri;
		if not e then return false;
		return new MyArray(e.votes).find (v) => v.id == @user.getId()

	buildTrackQueue: (queue) ->
		for elem in queue
			@buildTrackQueueElem(elem)

	buildTrackQueueElem: (elem) ->
		data = {};
		data.track = elem.track;
		data.votes = elem.votes;
		data.addedBy = elem.addedBy;
		if (elem.date) then data.date = new Date(elem.date);
		return data

	buildPlayers: (players) -> players.length != 0;

	loadRoomFromData: (roomData) =>
		@player = @buildPlayers(roomData.players);
		@trackQueue = @buildTrackQueue(roomData.queue);
		@currentTrack = if (roomData.currentTrack) then @buildTrackQueueElem(roomData.currentTrack) else null
		@admin = roomData.admin;
		for elem in @trackQueue
			elem.haveMyVote = @haveMyVote(elem.track.uri);
		@emit('change');

	refreshTrackQueue: () -> @webService.query("room/#{@name}").then @loadRoomFromData

	buildSearchResult: (searchResults) =>
		tracks = []
		for track in searchResults.tracks
			data = track;
			if not track.imgUrl? then data.imgUrl = "images/album.png";
			data.haveMyVote = @haveMyVote(track.uri);
			tracks.push(data);
		return {tracks: tracks};

	getHistory: () ->
		return @webService.query("room/#{@name}/history").then (data) =>
			data = @buildTrackQueue(data);
			for elem in data
				elem.haveMyVote = @haveMyVote(elem.track.uri);
			return data;

	getUsers:	() -> @webService.query("room/#{@name}/users");
	search:		(query) -> @webService.query("room/#{@name}/search", {query: query}).then @buildSearchResult
	nextTrack:	()	-> @webService.query("room/#{@name}/nexttrack");
	deleteTrack:	(uri)	-> @webService.query("room/#{@name}/deletetrack", {uri: uri});
	vote:		(uri)	=> @webService.query("room/#{@name}/vote", {uri:uri}).then @loadRoomFromData
	unvote:		(uri)	=> @webService.query("room/#{@name}/unvote", {uri:uri}).then @loadRoomFromData
	addAdmin:	(userId)-> @webService.query("room/#{@name}/addAdmin" , {userId: userId});
	delAdmin:	(userId)-> @webService.query("room/#{@name}/delAdmin" , {userId: userId});
