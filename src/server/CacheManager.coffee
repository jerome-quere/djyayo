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

class CacheManager

	@getAlbumImg : (uri) ->
		if !@cache? then @cache = {}
		if !@cache['albumImg']? then @cache['albumImg'] = {}
		@cache['albumImg'][uri] = When.defer()

		albumId = uri.split(':')[2];
		url = "http://open.spotify.com/album/#{albumId}"

		HttpClient.get(url).then (data) =>
			regex = /http:\/\/o.scdn.co\/300\/[^"]+/
			res = regex.exec(data)[0]
			@cache['albumImg'][uri].resolve(res);
		return (@cache['albumImg'][uri].promise)

module.exports = CacheManager