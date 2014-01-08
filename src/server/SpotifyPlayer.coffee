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
HttpClient = require("./HttpClient.coffee");
When = require('when');
Model = require('./Model.coffee');

class SpotifyPlayer extends EventEmitter
	constructor: (@client) ->
		@client.on('disconnect', @onDisconnect)
		@client.on('command', @onCommand)
		@toDo = [];

	play: (uri) =>
		@_pingPong(new Command('play', {uri:uri}))

	getId: () -> @client.getId()

	onCommand: (command, args) =>
		if (command.getName() == "endOfTrack")
			@emit('endOfTrack');
		else
			if (command.getName() == 'success')
				@toDo[0].defer.resolve(command.getArgs());
			else
				@toDo[0].defer.reject(command.getArgs());
			@toDo.shift();
			@_execToDo()

	onDisconnect: () =>
		@emit('disconnect')

	search: (query) =>
		@_pingPong(new Command('search', {query:query})).then (res) =>
			promises = for track in res.results.tracks
				do (track) =>
					Model.getAlbum(track.album.uri).then (album) ->
						track.album.imgUrl = album.imgUrl;
			count = promises.length
			defer = When.defer()
			for p in promises
				p.finally () =>
					if (--count == 0) then defer.resolve(res);
			return defer.promise


	_execToDo: () =>
		if (@toDo.length == 0 ) then return;
		@client.send(@toDo[0].cmd);

	_pingPong: (cmd) =>
		defer = When.defer();
		@toDo.push({cmd:cmd, defer:defer});
		if (@toDo.length == 1)
			@_execToDo();
		return defer.promise;

module.exports = SpotifyPlayer