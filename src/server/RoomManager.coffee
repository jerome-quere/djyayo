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

Room = require('./Room.coffee');
DatabaseManager = require('./DatabaseManager.coffee');

class RoomManager
	constructor: () ->
		@rooms = {};
		@db = new DatabaseManager();
		@db.on('onRoomList', @onRoomList);

	onRoomList: (rooms) =>
		@rooms = @db.getAllRooms();

	_getKeyFromName: (name) -> return name.toLowerCase();

	create: (name) ->
		if (!name) then return null;
		key = @_getKeyFromName(name);
		if (/^[a-z0-9A-Z_-]+$/.test(name))
			room = @db.createRoom(key);
			@rooms[name] = room;
			return (room);
		return null;

	getList: () ->
		names = []
		for key,room of @rooms
			names.push({name: key});
		return names

	get: (name) ->
		key = @_getKeyFromName(name);
		return if @rooms[key]? then @rooms[key] else null

module.exports = new RoomManager();