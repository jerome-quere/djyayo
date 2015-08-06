mongoose = require('mongoose');
EventEmitter = require("events").EventEmitter
TrackQueueElement = require('./TrackQueueElement.coffee');
Room = require('./Room.coffee');
UserManager = require('./UserManager.coffee');

class	DatabaseManager extends EventEmitter

	_instance = null;

	constructor: () ->
		if _instance
			return _instance;
		else
			_instance = @;
			@roomSaved = false;
			@rooms = {};
			@dbRooms = {};
			@db = mongoose.connect('mongodb://localhost/djyayo', @onDatabaseConnected);
			@roomSchema = new mongoose.Schema({
				name: 	String,
				tracks: [],
				users: 	[],
				admins: []
			});
			@roomModel = mongoose.model('room', @roomSchema);
			@refreshRoomList(@onRoomList);

	createRoom: (name) ->
		modelToSave = new @roomModel({name: name, tracks: [], users: [], admins: []});
		modelToSave.save(@onRoomSaved);
		@dbRooms[name] = {name: name, users: [], admins: [], tracks: []};
		return Room.room(name);

	refreshRoomList: (handler) ->
		@roomModel.find(null, handler);

	getAllRoomNames: () ->
		i = 0;
		res = [];
		while (i < @dbRooms.length)
			res.push(@dbRooms[i].name);
		return res;

	getAllRooms: () ->
		return @rooms;

	updateRoomModel: (roomName, callback) ->
		@dbRooms[roomName].tracks.sort((a, b) ->
			if ((a.upvotes - a.downvotes) > (b.upvotes - b.downvotes))
				return (-1);
			else if ((a.upvotes - a.downvotes) < (b.upvotes - b.downvotes))
				return (1);
			return (0);
		);
		@roomModel.update({name: roomName}, {
			name: roomName,
			users: @dbRooms[roomName].users,
			admins: @dbRooms[roomName].admins,
			tracks: @dbRooms[roomName].tracks
		}, callback);

	addSongInRoom: (userId, track, roomName) ->
		isInTracks = false;
		i = 0;
		while (i < @dbRooms[roomName].tracks.length)
			if (@dbRooms[roomName].tracks[i].track.uri == track.uri)
				isInTracks = true;
				break;
			i++;
		if (isInTracks == false)
			@dbRooms[roomName].tracks.push({track: track, upvotes: 0, downvotes: 0, creatorId: userId, isPlaying: false});
		@updateRoomModel(roomName, @onTrackAdded);

	addUserInRoom: (user, roomName) ->
		isUser = false;
		i = 0;
		while (i < @dbRooms[roomName].users.length)
			if (@dbRooms[roomName].users[i].user_id == user.id)
				isUser = true;
				break;
			i++;
		if (isUser == false)
			@dbRooms[roomName].users.push({user_id: user.id, upvoted: [], downvoted: []});
		for name,room of @dbRooms
			j = 0;
			while (j < room.users.length)
				k = 0;
				if (room.users[j].user_id == user.id)
					while (k < room.users[j].upvoted.length)
						uri = room.users[j].upvoted[k];
						@rooms[room.name].voteInit(room.users[j].user_id, uri);
						k++;
					k = 0;
					while (k < room.users[j].downvoted.length)
						uri = room.users[j].downvoted[k];
						@rooms[room.name].downvoteInit(room.users[j].user_id, uri);
						k++;
				j++;
		@updateRoomModel(roomName, @onUserAdded);

	addAdminInRoom: (user, roomName) ->
		i = 0;
		isAdmin = false;
		while (i < @dbRooms[roomName].admins.length)
			if (@dbRooms[roomName].admins[i].user_id == user.id)
				isAdmin = true;
				break;
			i++;
		if (isAdmin == false)
			console.log('Setting ' + user.id + ' as admin in ' + roomName);
			@dbRooms[roomName].admins.push({user_id: user.id});
			if (@roomSaved)
				console.log('Updating room model');
			@updateRoomModel(roomName, @onAdminAdded);
		@.on('onRoomSaved', () =>
			@roomSaved = true;
			@updateRoomModel(roomName, @onAdminAdded);
		);

	userVoteSong: (userId, track, roomName) ->
		i = 0;
		while (i < @dbRooms[roomName].users.length)
			if (@dbRooms[roomName].users[i].user_id == userId)
				update = false;
				k = 0;
				while (k < @dbRooms[roomName].users[i].upvoted.length)
					if (@dbRooms[roomName].users[i].upvoted[k] == track.uri)
						update = true;
						break;
					k++;
				j = 0;
				if (update == false)
					@dbRooms[roomName].users[i].upvoted.push(track.uri);
				while (j < @dbRooms[roomName].tracks.length)
					if (@dbRooms[roomName].tracks[j].track.uri == track.uri)
						@dbRooms[roomName].tracks[j].upvotes++;
						break;
					j++;
			i++;
		@updateRoomModel(roomName, @onVoteAdded);

	userUnvoteSong: (userId, trackUri, roomName) ->
		i = 0;
		while (i < @dbRooms[roomName].users.length)
			if (@dbRooms[roomName].users[i].user_id == userId)
				update = false;
				k = 0;
				while (k < @dbRooms[roomName].users[i].upvoted.length)
					if (@dbRooms[roomName].users[i].upvoted[k] == trackUri)
						update = true;
						break;
					k++;
				j = 0;
				if (update == false)
					@dbRooms[roomName].users[i].upvoted.splice(@dbRooms[roomName].users[i].upvoted.indexOf(trackUri));
				while (j < @dbRooms[roomName].tracks.length)
					if (@dbRooms[roomName].tracks[j].track.uri == trackUri)
						@dbRooms[roomName].tracks[j].upvotes--;
						@removeUpvotesForUser(@dbRooms[roomName].tracks[j].track.uri, roomName);
						if (@dbRooms[roomName].tracks[j].upvotes == 0)
							@removeDownvotesForUser(@dbRooms[roomName].tracks[j].track.uri, roomName);
							@dbRooms[roomName].tracks.splice(j, 1);
						break;
					j++;
			i++;
		@updateRoomModel(roomName, @onUnvoted);

	userDownvoteSong: (userId, track, roomName) ->
		console.log();
		i = 0;
		while (i < @dbRooms[roomName].users.length)
			if (@dbRooms[roomName].users[i].user_id == userId)
				update = false;
				k = 0;
				while (k < @dbRooms[roomName].users[i].downvoted.length)
					if (@dbRooms[roomName].users[i].downvoted[k] == track.uri)
						update = true;
						break;
					k++;
				j = 0;
				if (update == false)
					@dbRooms[roomName].users[i].downvoted.push(track.uri);
				while (j < @dbRooms[roomName].tracks.length)
					if (@dbRooms[roomName].tracks[j].track.uri == track.uri)
						@dbRooms[roomName].tracks[j].downvotes++;
						break;
					j++;
			i++;
		@updateRoomModel(roomName, @onSongDownvoted);

	userUndownvoteSong: (userId, trackUri, roomName) ->
		i = 0;
		while (i < @dbRooms[roomName].users.length)
			if (@dbRooms[roomName].users[i].user_id == userId)
				update = false;
				k = 0;
				while (k < @dbRooms[roomName].users[i].downvoted.length)
					if (@dbRooms[roomName].users[i].downvoted[k] == trackUri)
						update = true;
						break;
					k++;
				j = 0;
				if (update == false)
					@dbRooms[roomName].users[i].downvoted.splice(@dbRooms[roomName].users[i].downvoted.indexOf(trackUri));
				while (j < @dbRooms[roomName].tracks.length)
					if (@dbRooms[roomName].tracks[j].track.uri == trackUri)
						@dbRooms[roomName].tracks[j].downvotes--;
						@removeDownvotesForUser(@dbRooms[roomName].tracks[j].track.uri, roomName);
						break;
					j++;
			i++;
		@updateRoomModel(roomName, @onSongUndownvoted);

	removeSongForUsers: (trackUri, roomName) ->
		@removeDownvotesForUser(trackUri, roomName);
		@removeUpvotesForUser(trackUri, roomName);

	removeDownvotesForUser: (trackUri, roomName) ->
		room = @dbRooms[roomName];
		i = 0;
		while (i < room.users.length)
			j = 0;
			while (j < room.users[i].downvoted.length)
				if (room.users[i].downvoted[j] == trackUri)
					room.users[i].downvoted.splice(j, 1);
					break;
				j++;
			i++;

	removeUpvotesForUser: (trackUri, roomName) ->
		room = @dbRooms[roomName];
		i = 0;
		while (i < room.users.length)
			j = 0;
			while (j < room.users[i].upvoted.length)
				if (room.users[i].upvoted[j] == trackUri)
					room.users[i].upvoted.splice(j, 1);
					break;
				j++;
			i++;

	removeSongInRoom: (trackUri, roomName) ->
		i = 0;
		while (i < @dbRooms[roomName].tracks.length)
			if (@dbRooms[roomName].tracks[i].track.uri == trackUri)
				@dbRooms[roomName].tracks.splice(i, 1);
				@removeSongForUsers(trackUri, roomName);
				@updateRoomModel(roomName, @onSongRemoved);
				return;
			i++;

	removeFirstSongInRoom: (roomName) ->
		t = @dbRooms[roomName].tracks[0].track;
		@dbRooms[roomName].tracks.shift();
		@removeSongForUsers(t.uri, roomName);
		@updateRoomModel(roomName, @onSongRemoved);

	isAdminInRoom: (user, roomName) ->
		i = 0;
		if (@dbRooms[roomName] != undefined)
			while (i < @dbRooms[roomName].admins.length)
				if (@dbRooms[roomName].admins[i].user_id == user.id)
					return true;
				i++;
		return false;

	delAdminInRoom: (user, roomName) ->
		i = 0;
		@.on('onRoomSaved', () =>
			@roomSaved = true;
			@updateRoomModel(roomName, @onAdminDeleted);
		);
		while (i < @dbRooms[roomName].admins.length)
			if (@dbRooms[roomName].admins[i].user_id == user.id)
				@dbRooms[roomName].admins.splice(i, 1);
				@updateRoomModel(roomName, @onAdminDeleted);
				break;
			i++;

	# CALLBACKS
	onDatabaseConnected: (err) ->
		if (err)
			console.log(err);
		else
			console.log('[ OK ] Successfully connected to mongoDB server');

	onRoomList: (err, roomList) =>
		if (err)
			console.log(err);
		else
			i = 0;
			while (i < roomList.length)
				if (@rooms[roomList[i].name] == undefined)
					r = Room.room(roomList[i].name);
					@rooms[roomList[i].name] = r;
					@dbRooms[roomList[i].name] = roomList[i];
				i++;
		@emit('onRoomList', @rooms);

	onTrackAdded: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Track added');

	onUnvoted: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Vote removed');

	onSongDownvoted: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Song downvoted');

	onSongUndownvoted: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Song undownvoted');

	onUserAdded: (err) =>
		if (err)
			console.log(err);
		else
			console.log('User added');

	onAdminAdded: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Admin added');

	onAdminDeleted: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Admin deleted');

	onVoteAdded: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Vote added');

	onSongRemoved: (err) =>
		if (err)
			console.log(err);
		else
			console.log('Song removed');

	onRoomSaved: (err) =>
		if (err)
			console.log(err);
		else
			@emit('onRoomSaved');

module.exports = DatabaseManager;