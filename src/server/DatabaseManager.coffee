mongoose = require('mongoose');
EventEmitter = require("events").EventEmitter
Room = require('./Room.coffee');

class	DatabaseManager extends EventEmitter

	_instance = null;

	constructor: () ->
		if _instance
			return _instance;
		else
			_instance = @;
			@rooms = {};
			@dbRooms = {};
			@db = mongoose.connect('mongodb://localhost/djyayoTest', @onDatabaseConnected);
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

	addUserInRoom: (user, roomName) ->
		console.log('Adding', user.name, 'in', @dbRooms[roomName]);
		@dbRooms[roomName].users.push({user_id: user.id, upvoted: [], downvoted: []});
		@roomModel.update({name: roomName}, {
			name: roomName,
			users: @dbRooms[roomName].users,
			admins: @dbRooms[roomName].admins,
			tracks: @dbRooms[roomName].tracks
		}, @onUserAdded);

	addAdminInRoom: (user, roomName) ->
		console.log('Adding', user.name, 'as admin in', @dbRooms[roomName].name);
		i = 0;
		isAdmin = false;
		while (i < @dbRooms[roomName].admins.length)
			if (@dbRooms[roomName].admins[i].user_id == user.id)
				isAdmin = true;
				break;
			i++;
		if (isAdmin == false)
			@dbRooms[roomName].admins.push({user_id: user.id, upvoted: [], downvoted: []});
		@.on('onRoomSaved', () => 
			@roomModel.update({name: roomName}, {
				name: roomName,
				user: @dbRooms[roomName].user,
				admins: @dbRooms[roomName].admins,
				tracks: @dbRooms[roomName].tracks
			}, @onUserAdded);
		);

	isAdminInRoom: (user, roomName) ->
		i = 0;
		if (@dbRooms[roomName] != undefined)
			while (i < @dbRooms[roomName].admins.length)
				if (@dbRooms[roomName].admins[i].user_id == user.id)
					return true;
				i++;
		return false;

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
					console.log('===== FOUND ROOM =====');
					console.log(@dbRooms[roomList[i].name]);
					console.log('======================');
				i++;
		@emit('onRoomList', @rooms);

	onUserAdded: (err, msg) =>
		if (err)
			console.log(err);
		else
			console.log('User added:', msg);


	onRoomSaved: (err) =>
		if (err)
			console.log(err);
		else
			console.log('===== ON ROOM SAVED =====');
			@emit('onRoomSaved');

module.exports = DatabaseManager;
