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

EventEmitter = require('events').EventEmitter
When = require('when');
HttpClient = require('./HttpClient.coffee');
Logger = require('./Logger.coffee')

class SpotifyCommunicator extends EventEmitter

	constructor: () ->
		@player = null

	search: (args, resolver) =>
		p = HttpClient.get("http://ws.spotify.com/search/1/track.json?q=#{encodeURI(args.query)}");
		p.then (data) =>
			data = JSON.parse(data);
			resolver.resolve(@buildSearchResult(data));
		p.otherwise (error) ->
			resolver.reject(error);

	lookup: (args, resolver) =>
		console.log("http://ws.spotify.com/lookup/1/.json?uri=#{encodeURI(args.uri)}");
		p = HttpClient.get("http://ws.spotify.com/lookup/1/.json?uri=#{encodeURI(args.uri)}");
		p.then (data) =>
			console.log("LOOKUP OK")
			data = JSON.parse(data);
			resolver.resolve(@buildLookupResut(data));
		p.otherwise (error) ->
			console.log("ERROR #{error}");
			resolver.reject(error);

	buildSearchResult: (spRes) =>
		res = {};
		res.tracks = [];
		for spT in spRes.tracks
			t = {};
			t.name = spT.name;
			t.uri = spT.href;
			t.artists = [];
			for spA in spT.artists
				t.artists.push({name: spA.name, uri: spA.href});
			res.tracks.push(t);
		res.tracks = res.tracks.slice(0, 20);
		return (res);

	buildLookupResut: (spRes) -> return (spRes.track);


module.exports = SpotifyCommunicator;