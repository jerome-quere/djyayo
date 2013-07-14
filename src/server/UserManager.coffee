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
User = require('./User.coffee');

class UserManager
	constructor: () ->
		@users = {}

	add: (user) ->
		@users[user.getId()] = user;

	get: (userId) -> if @users[userId]? then @users[userId] else null


	loadFromFacebook: (token) ->
		promise = HttpClient.get("https://graph.facebook.com/me?access_token=#{token}");
		promise = promise.then (data) =>
			data = JSON.parse(data)
			if (data.id?)
				user = new User(data.id, data.first_name, "http://graph.facebook.com/#{data.id}/picture");
				@add(user);
				return (user);
			else
				throw "Error"
		return promise


	loadFromGoogle: (token) ->
		promise = HttpClient.get("https://www.googleapis.com/plus/v1/people/me?access_token=#{token}");
		promise = promise.then (data) =>
			data = JSON.parse(data)
			if data.id?
				user = new User(data.id, data.name.givenName, data.image.url)
				@add(user);
				return user;
			else
				throw "Error"

		return promise

module.exports = new UserManager();