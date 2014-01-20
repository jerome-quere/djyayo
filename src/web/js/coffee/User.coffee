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

class User extends EventEmitter

	constructor: (@webService, @$location, @$cookies) ->
		@_clear();
		@_loadToken()
		@refresh().finally () =>
			if @isLog() then @emit('login') else @emit('logout')

	isLog: () -> return @id != -1;
	getId: () -> @id;
	getName: () -> @name;
	getImgUrl: () -> @imgUrl


	loginWithFacebookToken: (token) =>
		@_login {method:"facebook", token:token}

	loginWithGoogleToken: (token) =>
		@_login {method:"google", token:token}

	logout: () ->
		@webService.setAccessToken(null)
		@_clear()
		@emit('logout');

	refresh: () =>
		p = @webService.query('me').then (data) =>
			@_update(data);
		p.then null, () =>
			@_clear()
		return p;


	_clear: () ->
		@id = -1
		@name = '';
		@imgUrl = '';

	_update: (userData) =>
		@id = userData.id
		@name = userData.name
		@imgUrl = userData.imgUrl

	_login: (data) ->
		@webService.query('login', data).then (data) =>
			@webService.setAccessToken(data.access_token);
			@refresh().then () =>
				@_saveToken(data.access_token)
				@emit('login');

	_loadToken: () =>
		token = @$cookies.access_token;
		@webService.setAccessToken(token);

	_saveToken: (token) =>
		@$cookies.access_token = token;