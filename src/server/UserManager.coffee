##
#The MIT License (MIT)
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

HttpClient = require('./HttpClient.coffee');
User = require('./User.coffee');

class UserManager
	constructor: () ->
		@users = {}

	add: (user) -> @users[user.getId()] = user;

	get: (userId) -> if @users[userId]? then @users[userId] else null


	loadFromFacebook: (token) ->
		promise = HttpClient.get("https://graph.facebook.com/me?access_token=#{token}");
		promise = promise.then (data) =>
			data = JSON.parse(data)
			if (data.id?)
				user = new User("facebook-#{data.id}", "#{data.first_name} #{data.last_name}" , "http://graph.facebook.com/#{data.id}/picture", token);
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
				user = new User("google-#{data.id}", "#{data.name.givenName} #{data.name.familyName}", data.image.url, token)
				@add(user);
				return user;
			else
				throw "Error"
		return promise

module.exports = new UserManager();
