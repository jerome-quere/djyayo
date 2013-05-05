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

EventEmitter = require('events').EventEmitter
HttpServer = require('./HttpServer.coffee')
SpotifyCommunicator = require('./SpotifyCommunicator.coffee');

class HttpCommunicator extends EventEmitter
	constructor: (@config) ->
		@httpServer = new HttpServer(@config.httpPort);
		@httpServer.on('request', @onHttpRequest)

	onHttpRequest: (clientId, request, response) =>
		@emit('httpRequest', clientId, request, response)

	run: () ->
		@httpServer.run();

module.exports = HttpCommunicator;