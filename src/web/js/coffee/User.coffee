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

	constructor: (@webService, @$location) ->
		super;
		@_clear();
		@refresh();

	getId: () -> @id;

	loginWithFacebookToken: (token) =>
		@webService.query('login', {method:"facebook", token:token}).then (data) =>
			@_update(data);
			@emitEvent('queueRefresh');

	loginWithGoogleToken: (token) =>
		@webService.query('login', {method:"google", token:token}).then (data) =>
			@_update(data);
			@emitEvent('queueRefresh');

	logout: () ->
		@webService.query('logout').then (httpRes) =>
			@_update(httpRes.data);
			@emitEvent('queueRefresh');

	refresh: () =>
		p = @webService.query('me').then (data) =>
			@_update(data);
		return p;

	_clear: () ->
		@id = -1
		@isLog = false;
		@votes = [];
		@name = '';

	_update: (userData) =>
		if (!userData?)
			@_clear();
			return;
		@id = userData.id;
		@name = userData.name;
		@imgUrl = userData.imgUrl;
		@isLog = true;