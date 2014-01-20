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

IdGenerator = require('./IdGenerator.coffee');
crypto = require('crypto')

class Session
	constructor: (@id, data) ->
		for key, value of data
			this[key] = value;
	getUserId: () -> @id;

class SessionManager
	constructor: () ->
		@sessions = {};
		@idGenerator = new IdGenerator()

	create: (data) ->
		md5 = crypto.createHash('md5');
		md5.update("#{data.id}-SpotifyDJ-#{Math.random()}");
		token = md5.digest('hex');
		@sessions[token] = new Session(@idGenerator.next(), data);
		return token;

	get: (token) ->
		if @sessions[token]?
			return @sessions[token]
		return null

module.exports = SessionManager;