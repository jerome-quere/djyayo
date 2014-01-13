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

child_process = require('child_process')
Config = require('./Config.coffee');
EventEmitter = require('events').EventEmitter
fn = require('when/function');
When = require('when');

class Player extends EventEmitter
	constructor: () ->
		@child = null;
		@buffer = "";
		@toDo = [];

	connect: (login, password) ->
		defer = When.defer();
		@child = child_process.spawn("./player");
		@child.on('exit', @onExit);
		@child.on('error', @onExit);
		@child.stdout.setEncoding('utf8');
		@child.stdout.on('data', @onReadyRead);
		@toDo.push (cmd) =>
			if (cmd.name == "success") then defer.resolve(true) else defer.reject("Can't connect to spotify");
		return defer.promise;

	onEndOfTrack: () => @emit('endOfTrack')

	onError: (e) =>
		console.log(e)
	onExit: () =>
		throw "Player have quit";
	onReadyRead: (data) =>
		@buffer += data;
		while ((idx = @buffer.indexOf('\n')) != -1)
			cmd = @buffer.substr(0, idx)
			idx2 = cmd.indexOf(' ');
			if (idx2 == -1) then idx2 = cmd.length;
			[cmd, param] = [cmd.substr(0, idx2), cmd.substr(idx2 + 1)];
			@buffer = @buffer.substr(idx + 1);
			@onCommand({name:cmd, param: param});

	onCommand: (cmd) =>
		if (cmd.name == 'endOfTrack')
			@onEndOfTrack();
		else
			@toDo.shift()(cmd);
			if (@toDo.length != 0)
				@toDo[0]();

	sendPingPong: (cmd, cb) ->
		f = () =>
			@child.stdin.write("#{cmd.name} #{cmd.param}\n");
			@toDo[0] = cb;
		if (@toDo.length != 0)
			@toDo.push f;
		else
			f();

	play: (uri) ->
		defer = When.defer();
		console.log("play [#{uri}]");
		@sendPingPong {name: "play", param:uri}, (cmd) ->
			if (cmd.name == "success")
				defer.resolve(true);
			else
				defer.reject("Can't play track");
		return defer.promise;


	search: (query) ->
		defer = When.defer()
		console.log("Search [#{query}]");
		@sendPingPong {name: "search", param: query}, (cmd) =>
			try
				res = JSON.parse(cmd.param);
				defer.resolve(@buildSearchResult(res));
			catch e
				console.log(e);
				defer.reject("Cant parse search result from player");
		return defer.promise;

	buildSearchResult: (result) ->
		res = {}
		res.tracks = [];
		for track in result.tracks
				t = {}
				t.name = track.name
				t.uri = track.uri
				t.artists = [{name:track.artists[0].name, uri:track.artists[0].uri}]
				t.album = {}
				t.album.name = track.album.name
				t.album.uri = track.album.uri
				res.tracks.push(t);
		return res;

module.exports = Player