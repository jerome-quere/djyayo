##
#The MIT License (MIT)
#
# Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##

Command = require('./Command.coffee');
TrackQueue = require('./TrackQueue.coffee');
MyArray = require('./MyArray.coffee');

class Room
	constructor: (@name) ->
		@players = new MyArray([]);
		@trackQueue = new TrackQueue(this);
		@currentTrack = null;
		@clients = new MyArray([]);
		@users = new MyArray([]);
		@admins = new MyArray([]);

	havePlayer: () -> @players.size() != 0;
	getMainPlayer: () -> @players.front();

	addPlayer: (player) ->
		@players.push_back(player);
		if (@players.size() == 1)
			@getMainPlayer().on('endOfTrack', @onEndOfTrack);
			@playNextTrack()
		player.on('disconnect', () => @onPlayerDisconnect(player));
		@changed();

	addUser: (user) ->
		if not (@users.find (u) -> u.getId() == user.getId())
			@users.push_back(user);

	getUsers: (user) -> @users.get();

	addClient: (client) ->
		@clients.push_back(client);

	delClient: (client) -> @clients.filter (c) -> c == client

	onPlayerDisconnect: (player) ->
		oldFront = @players.front();
		@players.filter (p) -> p == player
		if oldFront != @players.front() and @havePlayer()
			@players.front().on('endOfTrack', @onEndOfTrack);
		if !@havePlayer()
			@currentTrack = null;
		else
			@playNextTrack()
		@changed();

	onEndOfTrack: () => @playNextTrack()

	playNextTrack: () ->
		@currentTrack = null;
		if (!@trackQueue.empty())
			@currentTrack = @trackQueue.pop();
			@players.foreach (player) -> player.play(@currentTrack.getUri())
		else
			p.stop() for p in @players;
		@changed();

	vote: (userId, trackUri) ->
		if not @havePlayer then throw "No player connected"
		@getMainPlayer().lookup(trackUri).then (track) =>
			@trackQueue.vote(userId, track);
			if @currentTrack == null then @playNextTrack();
			@changed();

	unvote: (userId, uri) ->
		@trackQueue.unvote(userId, uri)
		@changed();

	search: (query) =>
		if not @havePlayer then throw "No player connected"
		@getMainPlayer().search(query).then (data) =>
			return data;

	addAdmin: (user) ->
		if !@isAdmin(user)
			@admins.push_back(user);
		@changed();

	delAdmin: (user) -> @admins.filter (u) -> u.getId() == user.getId()
	isAdmin: (user) -> @admins.find (u) -> user.getId() == u.getId()

	deleteTrack: (uri) ->
		@trackQueue.remove(uri);
		@changed();

	changed: () =>
		@clients.foreach (client) ->
			client.send(new Command('roomChanged'));

	getData: () ->
		data = {}
		data.name = @name;
		if (@currentTrack?) then data.currentTrack = @currentTrack.getData();
		data.players = for p in @players.get()
			{id: p.getId()}
		data.queue = @trackQueue.getData()
		return data;

module.exports = Room
