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

Command = require("./Command.coffee")
EventEmitter = require("events").EventEmitter

class SpotifyPlayer extends EventEmitter
	constructor: (@client) ->
		@client.on('disconnect', @onDisconnect)
		@client.on('command', @onCommand)

	play: (uri) =>
		@client.send(new Command('play', {uri:uri}))

	onCommand: (command) =>
		if (command.getName() == "endOfTrack")
			@emit('endOfTrack');

	onDisconnect: () =>
		@emit('disconnect')

module.exports = SpotifyPlayer