mongoose = require('mongoose');
fn = require('when/function');
async = require('async');
Room = require('./Room.coffee');

class	DatabaseManager
    constructor: () ->
        @rooms = {};
        @db = mongoose.connect('mongodb://localhost/djyayoTest', @onDatabaseConnection);
        @roomSavedDecorator = (roomName, room) => (err) => @onRoomSaved(err, roomName, room);
        @roomSchema = new mongoose.Schema({
            name: String,
            tracks: Array,
            users: Array
        });
        @roomModel = mongoose.model('room', @roomSchema);
        @roomModel.find(null, (err, rooms) =>
            i = 0;
            while (i < rooms.length)
                @rooms[rooms[i].name] = new Room(rooms[i].name);
                i++;
        );

    createRoom: (roomName, room) ->
        if (@rooms.length == 0)
            modelToSave = new @roomModel({name: roomName, tracks: [], users: []});
            modelToSave.save(@roomSavedDecorator(roomName, room));
        else
            for room in @rooms
                if room.name == roomName
                    console.log('[ERROR]: ' + roomName + ' already exists');
                    return;
            modelToSave = new @roomModel({name: roomName, tracks: [], users: []});
            modelToSave.save(@roomSavedDecorator(roomName, room));

    deleteRoom: (roomName) ->
        console.log('Delete room ' + roomName);

    addUserToRoom: (user, roomName) ->
        console.log('Add ' + user + ' to ' + roomName);

    setUserAsAdminInRoom: (userName, roomName, isAdmin) ->
        console.log('Setting ' + userName + ' as admin (' + isAdmin + ') in ' + roomName);

    removeUserFromRoom: (userName, roomName) ->
        console.log('Removing ' + userName + ' from ' + roomName);

    addSongToRoomTrackQueue: (track, roomName) ->
        console.log('Adding song ' + track + ' to ' + roomName);

    removeSongFromList: (songId, roomName) ->
        console.log('Removing song ' + songId + ' from ' + roomName);

    getAllRooms: () ->
        return @rooms;

    # CALLBACKS
    onRoomSaved: (err, roomName, room) =>
        if (err)
            console.log('[ ERROR ]: Create room failed', err);
        else
            @rooms[roomName] = room;
            console.log('[ OK ]: Room ' + roomName + ' created');

    onDatabaseConnection: (err) ->
        if (err)
            console.log(err);
        else
            console.log('[ OK ] Successfully connected to mongoDB server.');

    close: () ->
        @db.connection.close();

module.exports = new DatabaseManager();
