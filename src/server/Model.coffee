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

class Model

	@getAlbum: (albumUri) ->
		return CacheManager.get("album/#{albumUri}", () => @_loadAlbum(albumUri));


	@_loadAlbum: (albumUri) ->
		defer = When.defer();
		albumId = albumUri.split(':')[2];
		url = "http://open.spotify.com/album/#{albumId}"
		promise = HttpClient.get(url)
		promise.then (html) =>
			regex = new RegExp('http:\/\/o.scdn.co\/300\/[^"]+');
			imgUri = regex.exec(html)[0]
			defer.resolver.resolve({uri: albumUri, imgUri: imgUri});
		promise.otherwise (error) =>
			defer.reject(error);
		return (defer.promise);

module.exports = Model;