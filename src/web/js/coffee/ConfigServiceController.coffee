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



class ConfigServiceController

	constructor: () ->
		proto = window.location.protocol;
		host = window.location.hostname;
		port = if (location.port) then ":#{location.port}" else "";
		@config = {}
		@config['website'] = {url:"#{proto}//#{host}#{port}"}
		@config['webservice'] = {url: "#{proto}//#{host}#{port}"}
		@config['facebook'] = {appId: '114968378707310'}
		@config['google'] = {clientId: "452000358943.apps.googleusercontent.com"}
		@config['static'] = {}

		@hostConfs = {};
		@hostConfs['archlinux'] = @loadLocalhostConf;
		@hostConfs['dj.yayo.fr'] = @loadProdConf;
		if @hostConfs[host]? then @hostConfs[host]();

	loadLocalhostConf: () =>
		@config['website']['url'] = 'http://archlinux:8000'
		@config['webservice']['url'] = 'http://archlinux:4545'

	loadProdConf: () =>
		@config['website']['url'] = 'http://dj.yayo.fr'
		@config['webservice']['url'] = 'http://dj.yayo.fr:4545'

	get: (key) =>
		parts = key.split('.');
		obj = @config;
		for part in parts
			if !obj[part]?
				obj = null
				break;
			obj = obj[part]
		return obj
