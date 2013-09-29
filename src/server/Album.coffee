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

HttpClient = require('./HttpClient.coffee');
When = require('when');

class Album

	constructor: (@uri) ->
		@name = "";
		@artist = null;
		@released = 0
		@imgUrl = ''

	loadImgUrl: () =>
		defer = When.defer()
		url = "https://embed.spotify.com/oembed/?url=#{@uri}"
		promise = HttpClient.get(url)
		promise = promise.then (data) =>
			data = JSON.parse(data);
			@imgUrl = data.thumbnail_url;
			defer.resolver.resolve(true);
		promise.otherwise(defer.resolver.reject);
		return (defer.promise);


	loadFromSpotifyWs: (data, model) ->
		@name = data.name;
		@released = data.released;
		promise = @loadImgUrl();
		if (data['artist-id']? && data['artist-id'])
			promise2 = model.getArtist(data['artist-id']);
			promise2 = promise2.then (artist) =>
				@artist = artist;
			return (When.join(promise, promise2));
		return promise;

module.exports = Album;