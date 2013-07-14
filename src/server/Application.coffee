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

HttpCommunicator = require('./HttpCommunicator.coffee')
HttpErrors = require('./HttpErrors.coffee');
Logger = require('./Logger.coffee');
Model = require('./Model.coffee')
RoomManager = require('./RoomManager.coffee');
RouteManager = require('./RouteManager.coffee');
SpotifyPlayer = require('./SpotifyPlayer.coffee');
StaticContent = require('./StaticContent.coffee')
UserManager = require('./UserManager.coffee')
WebSocketCommunicator = require('./WebSocketCommunicator.coffee');

class Application

	constructor: () ->
		@users = {}
		@httpCom = new HttpCommunicator();
		@webSockCom = new WebSocketCommunicator(@httpCom.getNodeServer())
		@routeManager = @buildRouteManager()
		@httpCom.on('httpRequest', @onHttpRequest);
		@webSockCom.on('command', @onWebSocketCommand);


	buildRouteManager: () ->
		rm = new RouteManager();
		rm.addRoute('login', @onLoginRequest);
		rm.addRoute('logout', @onLogoutRequest);
		rm.addRoute("room/$room/search", @onSearchRequest);
		rm.addRoute("createRoom", @onCreateRoomRequest);
		rm.addRoute("room/$room/queue", @onQueueRequest);
		rm.addRoute("room/$room/vote", @onVoteRequest);
		rm.addRoute("room/$room/unvote", @onUnvoteRequest);
		rm.addRoute("me", @onMeRequest);
		rm.addRoute("room/$room", @onRoomRequest);
		rm.addRoute("album/$uri", @onAlbumRequest);
		rm.addRoute("track/$uri", @onTrackRequest);
		return rm;

	onHttpRequest: (session, request, response) =>
		response.enableCrossDomain();
		response.setMIME('application/json');
		if (request.getMethod() not in ["POST","GET"])
			response.end();
		promise = @routeManager.exec(session, request, response)
		if (!promise?)
			@onStaticRequest(session, request, response)
			return;
		promise.then (data) -> response.end(JSON.stringify({code: 200, message: "OK", data: data}));
		promise.then null, (error) ->
			console.log(error);
			response.end(JSON.stringify({code: 500, message: error, data: null}));

	onLoginRequest: (session, request, response) =>
		data = request.getData();
		if (data? and data.method? and data.method in ["facebook", "google"])
			if (data.method == "facebook")
				promise = UserManager.loadFromFacebook(data.token);
			else
				promise = UserManager.loadFromGoogle(data.token);
			return promise.then (user) =>
				session.login(user.id);
				return @onMeRequest(session, request, response)
		else
			throw HttpErrors.badParams()

	onLogoutRequest: (session, request, response) =>
		session.logout();
		return {};

	onMeRequest: (session, request, response) =>
		if (!session.isLog())
			return null;
		user = UserManager.get(session.getUserId())
		return user.getData();

	onCreateRoomRequest: (session, request, response) =>
		data = request.getData();
		room = null;
		if (data.name?)
			room = RoomManager.create(data.name)
			if (room?)
				return room.getData();
		throw HttpErrors.badParams()

	onRoomRequest: (session, request, response, data) =>
		room = RoomManager.get(data.room);
		if (!room?)
			throw HttpErrors.invalidRoomName()
		console.log(room.getData());
		return room.getData();

	onUnvoteRequest: (session, request, response, data) =>
		post = request.getData();
		room = RoomManager.get(data.room)
		if !room? then throw HttpErrors.invalidRoomName()
		if !session.isLog() then throw HttpErrors.mustBeLoggedIn()
		if !post.uri then throw HttpErrors.badParams()
		room.unvote(session.getUserId(), post.uri);
		return @onQueueRequest(session, request, response, data)

	onVoteRequest: (session, request, response, data) =>
		post = request.getData();
		room = RoomManager.get(data.room)
		if !room? then throw HttpErrors.invalidRoomName()
		if !session.isLog() then throw HttpErrors.mustBeLoggedIn()
		if !post.uri then throw HttpErrors.badParams()
		room.vote(session.getUserId(), post.uri);
		return @onQueueRequest(session, request, response, data)

	onQueueRequest: (session, request, response, data) =>
		room = RoomManager.get(data.room)
		console.log(room);
		if !room? then throw HttpErrors.invalidRoomName()
		return room.getQueueData();

	onSearchRequest: (session, request, response, data) =>
		room = RoomManager.get(data.room)
		post = request.getData();
		if !room? then throw HttpErrors.invalidRoomName()
		if !post.query then throw HttpErrors.badParams()
		return room.search(data.query).then (data) =>
			return {results:data}

	onAlbumRequest: (session, request, response, data) =>
		p = Model.getAlbum(data.uri);
		return p.then (album) ->
			response.enableCache()
			return {album:album}

	onTrackRequest: (session, request, response, data) =>
		p = Model.getTrack(data.uri);
		return p.then (track) ->
			response.enableCache()
			response.end(JSON.stringify({track:track}))

	onStaticRequest: (session, request, response) ->
		StaticContent.handle(request, response);

	onIAmAPlayerCommand: (client, command) =>
		if (!command.getArgs().room?)
			return;
		roomName = command.getArgs().room;
		if (!(room = RoomManager.get(roomName)))
			room = RoomManager.create(roomName);
		room.addPlayer(new SpotifyPlayer(client));

	onWebSocketCommand: (client, command) =>
		if (command.getName() == "iamaplayer")
			@onIAmAPlayerCommand(client, command)
	run : () ->
		@httpCom.run()

module.exports = Application;