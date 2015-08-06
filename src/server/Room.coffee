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

TrackQueue = require('./TrackQueue.coffee');
EventEmitter = require("events").EventEmitter;
RoomPlayerManager = require('./RoomPlayerManager.coffee');
RoomUserManager = require('./RoomUserManager.coffee');
RoomClientManager = require('./RoomClientManager.coffee');
RoomHistoryManager = require('./RoomHistoryManager.coffee');

class Room
	constructor: (@name) ->
		@playerManager = new RoomPlayerManager();
		@playerManager.on('endOfTrack', @onEndOfTrack);
		@playerManager.on('change', @onPlayerChange);

		@trackQueue = new TrackQueue(this);
		@trackQueue.on('change', @onTrackQueueChange);

		@userManager = new RoomUserManager(@name);
		@clientManager = new RoomClientManager
		@currentTrack = null;

		@historyManager = new RoomHistoryManager();

		@prevotes = [];
		@votes = {};
		@downvotes = {};

	# PLAYER MANAGER HANDLERS
	onEndOfTrack:	()	=>	@playNextTrack()
	onPlayerChange: ()	=>	@change()

	# TRACKQUEUE HANDLER
	onTrackQueueChange: ()	=>
		if @currentTrack == null then @playNextTrack();
		@change();

	# PLAYER RELATED ACTIONS
	havePlayer:	()	->	@playerManager.havePlayer()
	addPlayer:	(player) ->
		@playerManager.addPlayer(player);
		i = 0;
		while (i < @prevotes.length)
			@vote(@prevotes[i].id, @prevotes[i].uri);
			i++;

		@prevotes = [];

	playNextTrack:	()	->
		@currentTrack = null;
		if @playerManager.havePlayer() and not @trackQueue.empty()
			@currentTrack = @trackQueue.pop();
			@historyManager.addTrack(@currentTrack);
			@playerManager.play(@currentTrack);
		else
			@playerManager.stop();
		@change()
	search: (query) -> @playerManager.search(query);

	# TRACK QUEUE RELATED ACTIONS
	vote: (userId, trackUri) ->
		@playerManager.lookup(trackUri).then (track) =>
			@trackQueue.vote(userId, track);
			if (@votes[userId] == undefined)
				@votes[userId] = [];
			@votes[userId].push(trackUri);
	voteInit: (userId, trackUri) -> @playerManager.lookup(trackUri).then (track) => @trackQueue.voteInit(userId, track);
	prevote: (userId, trackUri) -> @prevotes.push({id: userId, uri: trackUri});
	unvote: (userId, uri) ->
		@trackQueue.unvote(userId, uri);
		if (@downvotes[userId] == undefined)
			@downvotes[userId] = [];
		@downvotes[userId].push(uri);
	predownvote: (userId, uri) -> @predownvotes.push({id: userId, uri: uri});
	downvote: (userId, trackUri) -> @playerManager.lookup(trackUri).then (track) => @trackQueue.downvote(userId, track);
	downvoteInit: (userId, trackUri) -> @playerManager.lookup(trackUri).then (track) => @trackQueue.downvoteInit(userId, track);
	undownvote: (userId, uri) -> @trackQueue.undownvote(userId, uri)
	deleteTrack: (uri) -> @trackQueue.remove(uri);

	# USERS RELATED ACTIONS
	addUser:	(user)	->	@userManager.addUser(user)
	getUsers:	(user)	->	@userManager.getUsers()
	addAdmin:	(user)	->	@userManager.addAdmin(user)
	delAdmin:	(user)	->	@userManager.delAdmin(user)
	isAdmin:	(user)	->	@userManager.isAdmin(user)

	# CLIENT RELATED ACTIONS
	addClient:	(client) ->	@clientManager.addClient(client)
	delClient:	(client) ->	@clientManager.delClient(client)
	change:		()	=>	@clientManager.change();

	# DATA GETTERS
	getData: () ->
		data = {}
		data.name = @name;
		if (@currentTrack)
			data.currentTrack = @currentTrack.getData();
		data.players = @playerManager.getData()
		data.queue = @trackQueue.getData()
		return data;

	getHistoryData: () -> @historyManager.getData();

module.exports.room = (name) -> return new Room(name);