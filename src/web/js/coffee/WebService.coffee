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

class WebService
	constructor: ($http, $q, @config)  ->
		@q = $q
		@http = $http
		@access_token = null;

	_buildQueryString: (params) =>
		tmp = [];
		for key, value of params
			tmp.push("#{key}=#{encodeURI(value)}");
		if (tmp.length == 0) then return ''
		return "?#{tmp.join('&')}";

	setAccessToken: (@access_token) ->
	query: (method, data) ->
		if (!data?) then data = {};
		if (@access_token?) then data.access_token = @access_token;
		return @http.get("#{@config.get('webservice.url')}/#{method}#{@_buildQueryString(data)}", {cache:false, twithCredentials: true}).then (httpRes) ->
			if (httpRes.data.code == 200)
				return httpRes.data.data
			else
				throw httpRes.data.message