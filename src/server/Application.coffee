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

User = require('./User.coffee');
HttpCommunicator = require('./HttpCommunicator.coffee')
SpotifyCommunicator = require('./SpotifyCommunicator.coffee')
ChildProcess = require('child_process');
fs = require('fs')
StaticContent = require('./StaticContent.coffee')
SpotifyCommandFactory = require('./SpotifyCommandFactory.coffee')
TrackQueue = require('./TrackQueue.coffee')
Model = require('./Model.coffee')
WebSocketCommunicator = require('./WebSocketCommunicator.coffee');
Logger = require('./Logger.coffee');

class Application

	constructor: () ->
		@httpCom = new HttpCommunicator();
		@spotifyCom = new SpotifyCommunicator();
		@webSockCom = new WebSocketCommunicator(@httpCom.getNodeServer())
		@httpCom.on('httpRequest', @onHttpRequest);
		@spotifyCom.on('commandReceived', @onSpotifyCommand)
		@spotifyCom.on('playerChanged', @onSpotifyPlayerChanged)
		@users = {}
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;

	getUserFromId: (userId) ->
		if (@users[userId]?)
			return @users[userId];
		return null;

	onHttpRequest: (session, request, response) =>
		actions = [];
		actions.push({pattern: "^/login$", action: @onLoginRequest});
		actions.push({pattern: "^/logout$", action: @onLogoutRequest});
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
		Logger.debug("HTTP: #{url}", request.getData());
		for action in actions
			regex = new RegExp("#{action.pattern}");
			if (regex.test(url))
				response.enableCrossDomain();
				response.setMIME('application/json');
				action.action(session, request, response)
				break;

	onLoginRequest: (session, request, response) =>
		data = request.getData();
		if (data? and data.method? and data.method == "facebook")
			user = new User();
			promise = user.loadFromFacebook(data.token);
			promise.then () =>
				@users[user.id] = user;
				session.login(user.id);
			promise.ensure () => @onMeRequest(session, request, response)

	onLogoutRequest: (session, request, response) =>
		session.logout();
		@onMeRequest(session, request, response)

	onMeRequest: (session, request, response) =>
		if (!session.isLog())
			response.end(JSON.stringify(null))
			return;
		user = @getUserFromId(session.getUserId())
		votes = @trackQueue.getVotes(user.id)
		data = user.getData();
		data['votes'] = votes;
		response.end(JSON.stringify(data))

	onPlayerRequest: (session, request, response) =>
		response.end(JSON.stringify({player: @spotifyCom.getPlayerInfos()}))

	onUnvoteRequest: (session, request, response) =>
		if (session.isLog())
			@trackQueue.unvote(session.getUserId(), request.getData().uri)
			@webSockCom.queueChanged()
		@onQueueRequest(session, request, response)

	onVoteRequest: (session, request, response) =>
		if (session.isLog())
			@trackQueue.vote(session.getUserId(), request.getData().uri)
			if (@currentTrack == null && @spotifyCom.isConnected())
				@playNextTrack()
			@webSockCom.queueChanged()
		@onQueueRequest(session, request, response)

	onQueueRequest: (session, request, response) =>
		res = {}
		res.queue = @trackQueue.getQueue();
		res.currentTrack = if (@currentTrack?) then @currentTrack.getData() else null;
		response.end(JSON.stringify(res))

	onSearchRequest: (session, request, response) =>
		data = request.getData();
		p = @spotifyCom.exec SpotifyCommandFactory.search(data.query)
		p.then (data) => response.end(JSON.stringify({results:data}))

	onAlbumRequest: (session, request, response) =>
		url = request.getUrl();
		data = new RegExp("^/album/\([0-9a-zA-Z:]+\)$").exec(url);
		albumUri = data[1];
		p = Model.getAlbum(albumUri);
		p.then (album) ->
			response.enableCache()
			response.end(JSON.stringify({album:album}))
		p.otherwise () ->
			response.end(JSON.stringify(null))

	onTrackRequest: (session, request, response) =>
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


	onStaticRequest: (session, request, response) ->
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

	onSpotifyPlayerChanged: () =>
		if (@currentTrack != null && !@spotifyCom.isConnected())
			@currentTrack = null;
			@webSockCom.queueChanged()
		if (@currentTrack == null && @spotifyCom.isConnected())
			@playNextTrack();
		@webSockCom.playerChanged()


	run : () ->
		@httpCom.run()
		@spotifyCom.run()

module.exports = Application;