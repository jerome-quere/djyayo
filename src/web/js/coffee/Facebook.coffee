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

class Facebook
	constructor: (@$rootScope, @$q, @config) ->
		@facebookLoaded = @$q.defer();
		@loadFacebookSDK();
		window.fbAsyncInit = @onFacebookSDKLoaded

	login: () ->
		defer = @$q.defer();
		@facebookLoaded.promise.then () =>
			FB.getLoginStatus (r) =>
				if (r.status == 'connected')
					@scopeApply () ->  defer.resolve(r.authResponse.accessToken);
				else
					FB.login (r) =>
						if (r.status == 'connected')
							@scopeApply () -> defer.resolve(r.authResponse.accessToken);
						else
							@scopeApply () -> defer.reject("Not Connected");
		return (defer.promise)


	scopeApply: (func) =>
		if (@$rootScope.$$phase && @$rootScope.$$phase == '$digest')
			func();
		else
			@$rootScope.$apply(func)

	loadFacebookSDK: () ->
		jQuery () ->
			fjs = document.getElementsByTagName('script')[0];
			js = document.createElement('script');
			js.id = 'facebook-jssdk';
			js.src = "//connect.facebook.net/en_US/all.js";
			fjs.parentNode.insertBefore(js, fjs);

	onFacebookSDKLoaded: () =>
		conf = {};
		conf['appId'] = '114968378707310';
		conf['channelUrl'] = "#{@config.get('website.url')}/channel.html";
		conf['status'] = true;
		conf['cookie'] = true;
		conf['xfbml'] = true;
		FB.init(conf);
		@scopeApply () =>
			@facebookLoaded.resolve(true);