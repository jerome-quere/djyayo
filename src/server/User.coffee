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

When = require('when')
HttpClient = require('./HttpClient.coffee');
nconf = require('nconf');

class User
	constructor: () ->
		@id = -1;
		@name = '';
		@imgUrl = '';

	loadFromFacebook: (token) ->
		promise = HttpClient.get("https://graph.facebook.com/me?access_token=#{token}");
		promise = promise.then (data) =>
			data = JSON.parse(data)
			if (data.id?)
				@id = data.id
				@name = data.first_name;
				@imgUrl = "http://graph.facebook.com/#{data.id}/picture";
				return (true);
			else
				throw "Error"
		return promise


	loadFromGoogle: (token) ->
		promise = HttpClient.get("https://www.googleapis.com/plus/v1/people/me?key=#{nconf.get('googleClientId')}&access_token=#{token}");
		promise = promise.then((data) =>
			data = JSON.parse(data)
			if data.id?
				@id = data.id
				@imgUrl = data.image.url
				@name = data.name.givenName
				return true;
			else
				throw "Error"

		)
		return promise


	getData: () -> {id: @id, name: @name, imgUrl: @imgUrl};

module.exports = User