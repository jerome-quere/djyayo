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

When = require('when');
HttpClient = require('./HttpClient.coffee');
CacheManager = require('./CacheManager.coffee');
Track = require('./Track.coffee');
Album = require('./Album.coffee');
Artist = require('./Artist.coffee');

class Model

	@getAlbum: (uri) ->
		return CacheManager.get("#{uri}", () => @_loadAlbum(uri));

	@getTrack: (uri) ->
		return CacheManager.get("#{uri}", () => @_loadTrack(uri))

	@getArtist: (uri) ->
		return CacheManager.get("#{uri}", () => @_loadArtist(uri))


	@_loadAlbum: (albumUri) ->
		defer = When.defer();
		url = "http://ws.spotify.com/lookup/1/.json?uri=#{albumUri}"
		console.log("Album Uri is", url)
		promise = HttpClient.get(url)
		promise = promise.then (jsonStr) =>
			data = JSON.parse(jsonStr)
			album = new Album(albumUri);
			promise2 = album.loadFromSpotifyWs(data.album, Model)
			promise2 = promise2.then () =>
				defer.resolver.resolve(album)
			promise2.otherwise(defer.resolver.reject)
		promise.otherwise(defer.resolver.reject);
		return (defer.promise);

	@_loadTrack: (trackUri) ->
		defer = When.defer()
		url = "http://ws.spotify.com/lookup/1/.json?uri=#{trackUri}"
		console.log("Track Uri is", url)
		promise = HttpClient.get(url)
		promise = promise.then (jsonStr) =>
			data = JSON.parse(jsonStr)
			track = new Track(trackUri)
			promise2 = track.loadFromSpotifyWs(data.track, Model);
			promise2.then (t) =>
				defer.resolver.resolve(track)
			promise2.otherwise(defer.resolver.reject)
		promise = promise.otherwise(defer.resolver.reject)
		return (defer.promise);

	@_loadArtist: (artistUri) ->
		defer = When.defer()
		url = "http://ws.spotify.com/lookup/1/.json?uri=#{artistUri}"
		console.log("Aritst Uri is", url)
		promise = HttpClient.get(url)
		promise = promise.then (jsonStr) =>
			data = JSON.parse(jsonStr)
			artist = new Artist(artistUri)
			artist.loadFromSpotifyWs(data.artist);
			defer.resolver.resolve(artist)
		promise = promise.otherwise(defer.resolver.reject)
		return (defer.promise);

module.exports = Model;