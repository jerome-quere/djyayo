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

http = require('http');
When =require('when')

class HttpClient
	@get: (url) ->
		defer = When.defer()
		get = http.get url, (res) =>
			data = ''
			resolver = defer.resolver
			if (res.statusCode != 200)
				resolver.reject("Error - HttpClient - Can't load #{url}");
				return
			res.setEncoding('utf8');
			res.on 'data', (chunk) ->
				data = "#{data}#{chunk}";
			res.on 'end', () ->
				resolver.resolve(data);

		get.on 'error', () =>
			defer.resolver.reject("Error - HttpClient - Can't load #{url}");
		return (defer.promise);


module.exports = HttpClient