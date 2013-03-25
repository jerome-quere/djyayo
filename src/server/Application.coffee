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

Client = require('./Client.coffee');
Communicator = require('./Communicator.coffee')
ChildProcess = require('child_process');
fs = require('fs')
jstd = require('./jstd.js');
StaticContent = require('./StaticContent.coffee')
SpotifyCommandFactory = require('./SpotifyCommandFactory.coffee')
TrackQueue = require('./TrackQueue.coffee')
CacheManager = require('./CacheManager.coffee');

class Application

	constructor: (@config) ->
		@communicator = new Communicator(@config);
		@communicator.on('httpRequest', @onHttpRequest)
		@clients = new jstd.map();
		@trackQueue = new TrackQueue(this);
		console.log("Application:\nHTTP Port #{@config.httpPort}\nSpotify Port #{config.spotifyPort}");

	getClientFromId: (clientId) ->
		it = @clients.find(clientId);
		if (it.neq @clients.end())
			return it.get().second
		client = new Client(clientId)
		@clients.insert(jstd.make_pair(clientId, client));
		return (client)

	onHttpRequest: (clientId, request, response) =>
		actions = [];
		actions.push({pattern: "^/search$", action: @onSearchRequest});
		actions.push({pattern: "^/play$", action: @onPlayRequest});
		actions.push({pattern: "^/queue$", action: @onQueueRequest});
		actions.push({pattern: "^/vote$", action: @onVoteRequest});
		actions.push({pattern: "^/unvote$", action: @onUnvoteRequest});
		actions.push({pattern: "^/me$", action: @onMeRequest});
		actions.push({pattern: "^/albumImg$", action: @onAlbumImgRequest});
		actions.push({pattern: "",  action: @onStaticRequest});

		console.log(request.getUrl());
		url = request.getUrl()
		for action in actions
			regex = new RegExp("#{action.pattern}");
			if (regex.test(url))
				action.action(@getClientFromId(clientId), request, response)
				break;

	onMeRequest: (client, request, response) =>
		votes = @trackQueue.getVotes(client.id)
		response.end(JSON.stringify({id:client.id, votes: votes}))

	onUnvoteRequest: (client, request, response) =>
		@trackQueue.unvote(client.id, request.getData().uri)
		queue = @trackQueue.getQueue();
		response.end(JSON.stringify({queue:queue}))

	onVoteRequest: (client, request, response) =>
		@trackQueue.vote(client.id, request.getData().uri)
		queue = @trackQueue.getQueue();
		response.end(JSON.stringify({queue:queue}))

	onQueueRequest: (client, request, response) =>
		queue = @trackQueue.getQueue();
		response.end(JSON.stringify({queue:queue}))

	onSearchRequest: (client, request, response) =>
		data = request.getData();
		@communicator.spotifyQuery(SpotifyCommandFactory.search(data.query)).then (data) =>
			response.end(JSON.stringify({results:data}))

	onPlayRequest: (client, request, response) =>
		data = request.getData();
		@communicator.spotifyQuery SpotifyCommandFactory.play(data.url), (data) =>
			response.end(JSON.stringify(data))

	onAlbumImgRequest: (client, request, response) =>
		data = request.getData();
		CacheManager.getAlbumImg(data.uri).then (url) ->
			response.end(JSON.stringify({uri:url}))

	onStaticRequest: (client, request, response) ->
		StaticContent.handle(request, response);

	run : () ->
		@communicator.run()

module.exports = Application;