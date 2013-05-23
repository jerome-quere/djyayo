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


class Config

	constructor: () ->
		@config = {}
		@config['website'] = {url:document.location.hostname}
		@config['webservice'] = {url:document.location.hostname}
		@config['facebook'] = {appId: '114968378707310'}
		@config['google'] = {clientId: "452000358943.apps.googleusercontent.com"}
		@config['static'] = {}

		@hostConfs = {};
		@hostConfs['localhost'] = @loadLocalhostConf;
		@hostConfs['dj.yayo.fr'] = @loadProdConf;
		host = window.location.hostname;
		if @hostConfs[host]? then @hostConfs[host]();

	loadLocalhostConf: () =>
		@config['website']['url'] = 'http://localhost:4242'
		@config['webservice']['url'] = 'http://localhost:4242'

	loadProdConf: () =>
		@config['website']['url'] = 'http://dj.yayo.fr:4242'
		@config['webservice']['url'] = 'http://dj.yayo.fr:4242'

	get: (key) =>
		parts = key.split('.');
		obj = @config;
		for part in parts
			if !obj[part]?
				obj = null
				break;
			obj = obj[part]
		return obj