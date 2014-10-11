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

TrackQueueElement = require('./TrackQueueElement.coffee');
EventEmitter = require("events").EventEmitter
MyArray = require('./MyArray.coffee');

class TrackQueue extends EventEmitter

	constructor:	() -> @tracks = new MyArray([]);
	empty:		() -> @tracks.empty();

	vote: (userId, track) ->
		t = @tracks.find (t) -> t.track.uri == track.uri
		if !t
			t = new TrackQueueElement(track, userId)
			@tracks.push_back(t);
		t.vote(userId);
		@_sort()
		@change();

	unvote: (userId, trackUri) ->
		tmp = @tracks.clone().filter((t) -> t.track.uri != trackUri)
		tmp.foreach (t) -> t.unvote(userId)
		@tracks.filter (t) -> t.getNbVotes() == 0
		@_sort()
		@change();

	downvote: (userId, track) ->
		t = @tracks.find (t) -> t.track.uri == track.uri
		if (!t?) then return;
		t.downvote(userId);
		@_sort()
		@change();

	undownvote: (userId, trackUri) ->
		t = @tracks.find (t) -> t.track.uri == trackUri
		if (!t?) then return;
		t.undownvote(userId)
		@_sort()
		@change();

	remove: (trackUri) ->
		@tracks.filter (t) -> t.track.uri == trackUri
		@change();

	getData: () ->
		queue = []
		@tracks.foreach (elem) -> queue.push(elem.getData())
		return (queue)

	pop: () -> @tracks.pop_front()

	_sort: () -> @tracks.sort((a, b) -> b.getScore() - a.getScore())

	getVotes: (clientId) ->
		res = []
		@tracks.foreach (elem) ->
			if elem.hasVote(clientId) then res.push(elem.getUri())
		return res

	change: () -> @emit('change');

module.exports = TrackQueue;
