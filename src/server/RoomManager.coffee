##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDj.
#
# SpotifyDj is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDj is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDj.If not, see <http://www.gnu.org/licenses/>.
##

Room = require('./Room.coffee');

class RoomManager
	constructor: () ->
		@rooms = {};

	create: (name) ->
		if (/^[a-z0-9A-Z_-]+$/.test(name))
			@rooms[name] = new Room(name);
			return (@rooms[name]);
		throw "Can't create room [#{name}]"

	get: (name) -> if @rooms[name]? then @rooms[name] else null

module.exports = new RoomManager();