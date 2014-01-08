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

When = require('when');

class CacheManager

	@timer = null;

	@initCache: () ->
		if !@cache? then @cache = {}
		if !@timer? then @timer= setTimeout(CacheManager.onTimeout, 1000 * 60 * 10)

	@onTimeout: () =>
		@cache = null;
		@timer = null;
		@initCache()

	@get : (key, loader) ->
		@initCache()
		if @cache[key]? then return @cache[key].promise;
		@cache[key] = When.defer()
		promise = loader()
		promise.then (data) =>
			@cache[key].resolver.resolve(data);
		promise.otherwise (error) =>
			@cache[key].resolver.reject(error);
			@cache[key] = null;
		return @cache[key].promise;

module.exports = CacheManager