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
IdGenerator = require('./IdGenerator.coffee');
HttpRequest = require('./HttpRequest.coffee');
HttpResponse = require('./HttpResponse.coffee');
crypto = require('crypto');

class HttpServer extends EventEmitter

	constructor: (@port) ->
		@server = http.createServer(@onRequest);
		@clients = [];
		@idGenerator = new IdGenerator();

	onRequest: (request, response) =>
		response = new HttpResponse(response);
		request = new HttpRequest(request, response);
		request.on("requestComplete", @onRequestComplete)

	onRequestComplete: (request, response) =>
		client = @getClientFromRequest(request);
		response.setCookie("sessionId", client.sessionId);
		@emit('request', client.id, request, response)

	getClientFromRequest: (request) =>
		cookies = request.getCookies()
		if (cookies.sessionId?)
			client = @getClientFromSessionId(cookies.sessionId);
			if (client?) then return client;
		clientId = @idGenerator.next()
		hash = crypto.createHash('sha256');
		hash.update("#{clientId}-SpotifyDJ");
		sessionId = hash.digest('hex');
		client = {id: clientId, sessionId: sessionId};
		@clients.push(client);
		return	client

	getClientFromSessionId: (sessionId) ->
		for client in @clients
			if "#{client.sessionId}" == sessionId
				return client
		return null;

	getClientIdFromSessionId: (sessionId) =>
		client = @getClientFromSessionId(sessionId);
		if (client?)
			return client.id;
		return (-1);

	getNodeServer: () -> @server;

	run: () ->
		@server.listen(@port);


module.exports = HttpServer