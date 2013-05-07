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
HttpCommunicator = require('./HttpCommunicator.coffee')
SpotifyCommunicator = require('./SpotifyCommunicator.coffee')
ChildProcess = require('child_process');
fs = require('fs')
StaticContent = require('./StaticContent.coffee')
SpotifyCommandFactory = require('./SpotifyCommandFactory.coffee')
TrackQueue = require('./TrackQueue.coffee')
Model = require('./Model.coffee')
jstd = require('./jstd.js');
WebSocketCommunicator = require('./WebSocketCommunicator.coffee');

class Application

	constructor: (@config) ->
		@httpCom = new HttpCommunicator(@config);
		@spotifyCom = new SpotifyCommunicator(@config);
		@webSockCom = new WebSocketCommunicator(@httpCom.getNodeServer())
		@httpCom.on('httpRequest', @onHttpRequest);
		@spotifyCom.on('commandReceived', @onSpotifyCommand)
		@spotifyCom.on('playerChanged', @onSpotifyPlayerChanged)
		@clients = new jstd.map();
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;
		console.log("Application:\nHTTP Port #{@config.httpPort}");

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
		actions.push({pattern: "^/queue$", action: @onQueueRequest});
		actions.push({pattern: "^/vote$", action: @onVoteRequest});
		actions.push({pattern: "^/unvote$", action: @onUnvoteRequest});
		actions.push({pattern: "^/me$", action: @onMeRequest});
		actions.push({pattern: "^/player$", action: @onPlayerRequest});
		actions.push({pattern: "^/album/[0-9a-zA-Z:]+$", action: @onAlbumRequest});
		actions.push({pattern: "^/track/[0-9a-zA-Z:]+$", action: @onTrackRequest});
		actions.push({pattern: "", action: @onStaticRequest});
		url = request.getUrl()
		console.log("HTTP: #{url}", request.getData());
		for action in actions
			regex = new RegExp("#{action.pattern}");
			if (regex.test(url))
				response.enableCrossDomain();
				action.action(@getClientFromId(clientId), request, response)
				break;

	onMeRequest: (client, request, response) =>
		votes = @trackQueue.getVotes(client.id)
		response.end(JSON.stringify({id:client.id, votes: votes}))

	onPlayerRequest: (client, request, response) =>
		response.end(JSON.stringify({player: @spotifyCom.getPlayerInfos()}))

	onUnvoteRequest: (client, request, response) =>
		@trackQueue.unvote(client.id, request.getData().uri)
		@onQueueRequest(client, request, response)
		@webSockCom.queueChanged()

	onVoteRequest: (client, request, response) =>
		@trackQueue.vote(client.id, request.getData().uri)
		if (@currentTrack == null)
			@playNextTrack()
		@onQueueRequest(client, request, response)
		@webSockCom.queueChanged()

	onQueueRequest: (client, request, response) =>
		res = {}
		res.queue = @trackQueue.getQueue();
		res.currentTrack = if (@currentTrack?) then @currentTrack.getData() else null;
		response.end(JSON.stringify(res))

	onSearchRequest: (client, request, response) =>
		data = request.getData();
		p = @spotifyCom.exec SpotifyCommandFactory.search(data.query)
		p.then (data) => response.end(JSON.stringify({results:data}))

	onAlbumRequest: (client, request, response) =>
		url = request.getUrl();
		data = new RegExp("^/album/\([0-9a-zA-Z:]+\)$").exec(url);
		albumUri = data[1];
		p = Model.getAlbum(albumUri);
		p.then (album) ->
			response.enableCache()
			response.end(JSON.stringify({album:album}))
		p.otherwise () ->
			response.end(JSON.stringify(null))

	onTrackRequest: (client, request, response) =>
		url = request.getUrl();
		data = new RegExp("^/track/\([0-9a-zA-Z:]+\)$").exec(url);
		trackUri = data[1];
		p = Model.getTrack(trackUri);
		p.then (track) ->
			response.enableCache()
			response.end(JSON.stringify({track:track}))
		p.otherwise (e) ->
			console.log(e)
			response.end(JSON.stringify(null))


	onStaticRequest: (client, request, response) ->
		StaticContent.handle(request, response);

	onEndOfTrack: () =>
		@playNextTrack()

	playNextTrack: () ->
		if (@currentTrack != null)
			@currentTrack = null;
		if (@trackQueue.empty())
			return;
		@currentTrack = @trackQueue.pop();
		@webSockCom.queueChanged()
		p = @spotifyCom.exec SpotifyCommandFactory.play(@currentTrack.getUri())
		p.otherwise () => @playNextTrack()

	onSpotifyCommand: (command) =>
		console.log("Spotify Command : #{command}");
		@onEndOfTrack();

	onSpotifyPlayerChanged: () => @webSockCom.playerChanged()


	run : () ->
		@httpCom.run()
		@spotifyCom.run()

module.exports = Application;