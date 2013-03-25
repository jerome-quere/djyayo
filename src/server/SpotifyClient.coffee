##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDJ.
#
# SpotifyDJ is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDJ is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDJ.If not, see <http://www.gnu.org/licenses/>.
##

net = require('net');
EventEmitter = require('events').EventEmitter
WebSocket = require('ws')
Mopidy = require('./Mopidy.js');
When = require('when');

class SpotifyClient extends EventEmitter

	constructor: (@port) ->

		@client = new Mopidy({webSocketUrl: "ws://localhost:6680/mopidy/ws/", autoConnect: false});
		@client.on("state:online", @onStatusOnline);


	connect: () ->
		@client.connect();

	search: (args, resolver) =>
		console.log("Lauch Search");
		@client.library.search({any:args.query}).then (data) ->
			resolver.resolve(data[1].tracks)

	lookup: (args, resolver) =>
		@client.library.lookup(args.uri).then (data) ->
			resolver.resolve(data)

	query: (cmd) ->
		actions = {};
		actions['search'] = @search
		actions['lookup'] = @lookup
		deferer = When.defer()
		if actions[cmd.cmd]?
			actions[cmd.cmd](cmd.args, deferer.resolver);
		else
			deferer.resolver.reject("Command Not found #{cmd.cmd}");
		return (deferer.promise);

	onStatusOnline: () =>
		console.log("Spotify is online");

	onData: (data) =>
		@buffer.add(data)


module.exports = SpotifyClient;