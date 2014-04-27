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

class UserServiceController extends EventEmitter

	constructor: (@webService, @$location, @$cookies) ->
		@_clear();
		@_loadToken()
		@refresh().finally () => if @isLog() then @emit('login') else @emit('logout')

	isLog:	()	-> @id != -1;
	getId:	()	-> @id;
	getName: ()	-> @name;
	getImgUrl: ()	-> @imgUrl

	loginWithFacebookToken: (token) => @_login {method: "facebook", token: token}
	loginWithGoogleToken:	(token) => @_login {method: "google", token: token}

	logout: () ->
		@webService.setAccessToken(null)
		@_clear()
		@_saveToken('');
		@emit('logout');

	refresh: () =>
		p = @webService.query('me').then (data) => @_update(data);
		p.catch () => @_clear()
		return p;

	_clear: () ->
		@id = -1
		@name = '';
		@imgUrl = '';

	_update: (userData) =>
		@id	= userData.id
		@name	= userData.name
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

	_saveToken: (token) => @$cookies.access_token = token;
