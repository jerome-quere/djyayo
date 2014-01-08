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

Config = require('./Config.coffee');
EventEmitter = require('events').EventEmitter
fn = require('when/function');
spotify = require('./spotify.js')({ appkeyFile: Config.get('spKey') })
When = require('when');


class Player extends EventEmitter
	constructor: () ->
		spotify.player.on("player_end_of_track", @onEndOfTrack);

	connect: (login, password) ->
		defered = When.defer()
		spotify.login login, password, false, false
		spotify.ready () =>
			console.log("Spotify connected")
			defered.resolver.resolve(true);
		return defered.promise;

	onEndOfTrack: () => @emit('endOfTrack')

	play: (uri) ->
		defer = When.defer();
		track = spotify.createFromLink(uri)
		if !track? then defer.reject("Invalid URI")
		spotify.player.play(track)
		console.log('Playing: %s - %s', track.artists[0].name, track.name);
		defer.resolve(true);
		return defer.promise;


	search: (query) ->
		defer = When.defer()
		search = new spotify.Search(query);
		search.execute (err, res) =>
			if (err?)
				defer.reject(err);
			else
				defer.resolve(@buildSearchResult(res))
		return defer.promise;

	buildSearchResult: (result) ->
		res = {}
		res.tracks = [];
		for track in result.tracks
				t = {}
				t.name = track.name
				t.uri = track.link
				t.artists = [{name:track.artists[0].name, uri:track.artists[0].link}]
				t.album = {}
				t.album.name = track.album.name
				t.album.uri = track.album.link
				res.tracks.push(t);
		return res;

module.exports = Player