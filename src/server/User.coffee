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

Facebook = require('./Facebook.coffee');
When = require('when')

class User
	constructor: () ->
		@id = -1;
		@name = '';
		@imgUrl = '';

	loadFromFacebook: (token) ->
		defer = When.defer();
		Facebook.setAccessToken(token).api '/me', (err, data) =>
			if (err?)
				defer.resolver.reject(err);
				return
			@id = data.id
			@name = data.first_name;
			@imgUrl = "http://graph.facebook.com/#{data.id}/picture";
			defer.resolver.resolve(true);
		return defer.promise

	getData: () -> {id: @id, name: @name, imgUrl: @imgUrl};

module.exports = User