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

class Google
	constructor: (@$rootScope, @$q, @config) ->
		@googleLoaded = @$q.defer();
		@loadGoogleSDK();

	login: () =>
		defer = @$q.defer();
		@googleLoaded.promise.then () =>
			params = {};
			params.client_id = @config.get("google.clientId");
			params.imediate = true;
			params.scope = 'https://www.googleapis.com/auth/plus.me'
			gapi.auth.authorize params, (authResponse) =>
				@scopeApply () =>
					defer.resolve(authResponse.access_token);

		return (defer.promise)


	scopeApply: (func) =>
		if (@$rootScope.$$phase && @$rootScope.$$phase == '$digest')
			func();
		else
			@$rootScope.$apply(func)

	loadGoogleSDK: () ->
		jQuery () =>
			window.googleAsyncInit = @onGoogleSDKLoaded
			po = document.createElement('script');
			po.type = 'text/javascript';
			po.async = true;
			po.src = 'https://apis.google.com/js/client:plusone.js?onload=googleAsyncInit';
			s = document.getElementsByTagName('script')[0];
			s.parentNode.insertBefore(po, s);

	onGoogleSDKLoaded: () =>
		@scopeApply () =>
			@googleLoaded.resolve(true);