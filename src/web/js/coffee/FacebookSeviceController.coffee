##
# The MIT License (MIT)
#
# Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##

class FacebookServiceController
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
					FB.login((r) =>
						if (r.status == 'connected')
							@scopeApply () -> defer.resolve(r.authResponse.accessToken);
						else
							@scopeApply () -> defer.reject("Not Connected");
					, {scope: "user_photos"});
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
		conf['appId'] = @config.get('facebook.appId')
		conf['channelUrl'] = "#{@config.get('website.url')}/channel.html";
		conf['status'] = true;
		conf['cookie'] = true;
		conf['xfbml'] = true;
		FB.init(conf);
		@scopeApply () =>
			@facebookLoaded.resolve(true);
