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

class WebServiceServiceController
	constructor: (@$http, @$q, @config)  ->
		@access_token = null;

	_buildQueryString: (params) =>
		tmp = [];
		for key, value of params
			tmp.push("#{key}=#{encodeURI(value)}");
		return if (tmp.length != 0) then "?#{tmp.join('&')}" else ''

	setAccessToken: (@access_token) ->
	query: (method, data) =>
		if (!data?) then data = {};
		if (@access_token?) then data.access_token = @access_token;
		return @$http.get("#{@config.get('webservice.url')}/#{method}#{@_buildQueryString(data)}", {cache:false}).then (httpRes) =>
			if (httpRes.data.code != 200) then throw httpRes.data.message
			return httpRes.data.data
