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

	onHttpRequest: (request, response) =>
		response.enableCrossDomain();
		response.setMIME('application/json');
		response.disableCache();
		if (request.getMethod() not in ["POST","GET"])
			response.end();
		promise = @routeManager.exec(request, response)
		if (!promise?)
			@onStaticRequest(request, response)
			return;
		promise.then (data) -> response.end(JSON.stringify({code: 200, msg: "Success", data: data}));
		promise.then null, (error) ->
			code = if (error.code?) then error.code else 500;
			msg = if (error.msg?) then error.msg else "" + error;
			if (error.stack) then console.log(error.stack);
			response.end(JSON.stringify({code: code, msg: msg, data: null}));

	onLoginRequest: (request, response) =>
		data = request.getQuery();
		if (data? and data.method? and data.method in ["facebook", "google"])
			if (data.method == "facebook")
				promise = UserManager.loadFromFacebook(data.token);
			else
				promise = UserManager.loadFromGoogle(data.token);
			return promise.then (user) =>
				request.getSession().login(user.id);
				return @onMeRequest(request, response)
		else
			throw HttpErrors.badParams()

	onLogoutRequest: (request, response) =>
		request.getSession().logout();
		return {};

	onMeRequest: (request, response) =>
		if (!request.getSession().isLog())
			return null;
		user = UserManager.get(request.getSession().getUserId())
		return user.getData();

	onCreateRoomRequest: (request, response) =>
		data = request.getData();
		room = null;
		if (data.name?)
			room = RoomManager.create(data.name)
			if (room?)
				return room.getData();
		throw HttpErrors.badParams()

	onRoomRequest: (request, response, data) =>
		room = RoomManager.get(data.room);
		if (!room?)
			throw HttpErrors.invalidRoomName()
		return room.getData();

	onUnvoteRequest: (request, response, data) =>
		get = request.getQuery();
		room = RoomManager.get(data.room)
		if !room? then throw HttpErrors.invalidRoomName()
		if !request.getSession().isLog() then throw HttpErrors.mustBeLoggedIn()
		if !get.uri then throw HttpErrors.badParams()
		room.unvote(request.getSession().getUserId(), get.uri);
		return @onRoomRequest(request, response, data)

	onVoteRequest: (request, response, data) =>
		get = request.getQuery();
		room = RoomManager.get(data.room)
		if !room? then throw HttpErrors.invalidRoomName()
		if !request.getSession().isLog() then throw HttpErrors.mustBeLoggedIn()
		if !get.uri then throw HttpErrors.badParams()
		return Model.getTrack(get.uri).then (track) =>
			room.vote(request.getSession().getUserId(), track)
			return @onRoomRequest(request, response, data)

	onSearchRequest: (request, response, data) =>
		room = RoomManager.get(data.room)
		get = request.getQuery();
		if !room? then throw HttpErrors.invalidRoomName()
		if !get.query then throw HttpErrors.badParams()
		return room.search(get.query)

	onAlbumRequest: (request, response, data) =>
		p = Model.getAlbum(data.uri);
		return p.then (album) ->
			response.enableCache()
			return {album:album}

	onTrackRequest: (request, response, data) =>
		p = Model.getTrack(data.uri);
		return p.then (track) ->
			response.enableCache()
			response.end(JSON.stringify({track:track}))

	onStaticRequest: (request, response) ->
		StaticContent.handle(request, response);

	onIAmAPlayerCommand: (client, command) =>
		if (!command.getArgs().room?)
			return;
		roomName = command.getArgs().room;
		room = RoomManager.get(roomName);
		if (!room)
			room = RoomManager.create(roomName);
		room.addPlayer(new SpotifyPlayer(client));

	onChangeRoomCommand: (client, command) =>
		room = RoomManager.get(command.getArgs().room);
		if (!room) then return;
		room.addClient(client);

	onWebSocketCommand: (client, command) =>
		if (command.getName() == "iamaplayer")
			@onIAmAPlayerCommand(client, command)
		if (command.getName() == "changeRoom")
			@onChangeRoomCommand(client, command);
	run : () ->
		@httpCom.run()

module.exports = Application;