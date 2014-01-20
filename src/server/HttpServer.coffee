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

http = require('http');
EventEmitter = require('events').EventEmitter
HttpRequest = require('./HttpRequest.coffee');
HttpResponse = require('./HttpResponse.coffee');

class HttpServer extends EventEmitter

	constructor: (@port) ->
		@server = http.createServer(@onRequest);

	onRequest: (request, response) =>
		response = new HttpResponse(request, response);
		request = new HttpRequest(request, response);
		request.on("requestComplete", @onRequestComplete)

	onRequestComplete: (request, response) =>
		@emit('request', request, response)


	getNodeServer: () -> @server;
	getPort: () -> return @port;

	run: () ->
		@server.listen(@port);


module.exports = HttpServer