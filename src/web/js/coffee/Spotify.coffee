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

class Spotify

	constructor: ($cacheFactory, $q, @webService) ->
		@cache = $cacheFactory('Spotify');
		@q = $q;

	getTrack: (uri) =>
		if !uri? then return null;
		res = @cache.get(uri)
		if res? then return (res.promise);
		defer = @q.defer()
		@cache.put(uri, defer)
		promise = @_loadTrack(uri)
		promise = promise.then (track) =>
			defer.resolve(track)
		promise = promise.then null, (e) =>
			defer.reject(e)
			@cache.remove(uri)
		return (defer.promise);

	_loadTrack: (uri) ->
		defer = @q.defer()
		promise = @webService.query("track/#{uri}")
		promise = promise.then (response) =>
			if (response.data.track?)
				track = new Track();
				track.loadFromWsData(response.data.track);
				defer.resolve(track)
			else
				defer.reject("Can't load 'track/#{uri}'");
		promise = promise.then null, () =>
			defer.reject("Can't load 'track/#{uri}'");
		return (defer.promise)