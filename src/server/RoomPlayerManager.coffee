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

EventEmitter = require("events").EventEmitter
MyArray = require('./MyArray.coffee');

class RoomPlayerManager extends EventEmitter
	constructor: () ->
		@players = new MyArray([]);

	havePlayer:	()	-> @players.size() != 0;
	endOfTrack:	()	=> @emit('endOfTrack');
	change:		()	-> @emit('change');
	play:		(track)	-> @players.foreach (player) -> player.play(track.getUri())
	stop:		()	-> @players.foreach (player) -> player.stop();

	getData:	()	->
		players = []
		@players.foreach (p) ->
			players.push {id: p.getId()};
		return players;

	getMainPlayer: () ->
		if not @havePlayer() then throw "No player connected"
		return @players.front();

	addPlayer:	(player) ->
		player.on('disconnect', () => @onPlayerDisconnect(player));
		@players.push_back(player);
		if (@players.size() == 1)
			@getMainPlayer().on('endOfTrack', @endOfTrack);
			@endOfTrack();
		@change();

	onPlayerDisconnect: (player) ->
		old = @players.front();
		@players.filter (p) -> p == player
		if old != @players.front() and @havePlayer()
			@getMainPlayer().on('endOfTrack', @endOfTrack);
			@endOfTrack();
		@change();

	search: (query) -> @getMainPlayer().search(query);
	lookup: (uri) -> @getMainPlayer().lookup(uri)


module.exports = RoomPlayerManager;
