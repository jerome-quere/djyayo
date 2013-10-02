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
lame = require('lame');
Speaker = require('speaker');
Spotify = require('spotify-web');
When = require('when');
xml2js = require 'xml2js'

class Player extends EventEmitter
	constructor: () ->
		@spotify = null;

	connect: (login, password) ->
		defered = When.defer()
		Spotify.login login, password, (err, spotify) =>
			if (err)
				defered.resolver.reject(err)
				return;
			@spotify = spotify
			console.log("Contry : #{@spotify.country}");
			defered.resolver.resolve(true);
		return defered.promise;

	onEndOfTrack: () => @emit('endOfTrack')

	play: (uri) ->
		defer = When.defer();
		@spotify.get uri, (err, track) =>
			defer.resolve(fn.call((err, track) =>
				if (err) then throw err;
				console.log('Playing: %s - %s', track.artist[0].name, track.name);
				track.play().pipe(new lame.Decoder()).pipe(new Speaker()).on 'finish', () =>
					@onEndOfTrack()
			, err, track));
		return defer.promise;


	search: (query) ->
		defer = When.defer()
		@spotify.search query, (err, res) =>
			if (err?)
				defer.reject(err);
			else
				parser = new xml2js.Parser()
				parser.parseString res, (err, xml) =>
					if err then return defer.reject(err);
					defer.resolve(fn.call(@buildSearchResult, xml));
		return defer.promise;

	buildSearchResult: (xml) ->
		res = {}
		res.tracks = [];
		if (xml.result.tracks[0])
			for track in xml.result.tracks[0].track
				t = {}
				t.name = track.title[0];
				t.uri = Spotify.id2uri('track', track.id[0]);
				t.artists = [{name:track.artist[0], uri:Spotify.id2uri('artist', track['artist-id'][0])}]
				t.album = {}
				t.album.name = track.album[0]
				t.album.uri = Spotify.id2uri('album', track['album-id'][0]);
				t.album.imgUrl = null;
				if (track['cover']?)
					t.album.imgUrl = "https://d3rt1990lpmkn.cloudfront.net/300/#{track['cover'][0]}";
				res.tracks.push(t);
		return res;

module.exports = Player