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

class TrackQueue

	constructor: () ->
		@tracks = []

	empty: () ->
		return (@tracks.length == 0)

	indexOf: (trackUri) ->
		i = 0
		while (i < @tracks.length)
			if (@tracks[i].track.uri == trackUri)
				return (i)
			i++
		return (-1)

	vote: (clientId, track) ->
		if ((idx = @indexOf(track.uri)) != -1)
			return @tracks[idx].vote(clientId)
		elem = new TrackQueueElement(track)
		elem.vote(clientId)
		@tracks.push(elem);

	unvote: (clientId, trackUri) ->
		if ((idx = @indexOf(trackUri)) != -1)
			@tracks[idx].unvote(clientId)
			if (@tracks[idx].getNbVotes() == 0)
				@tracks.splice(idx, 1);

	getNext: () ->
		@tracks.sort((a, b) -> a.getNbVotes() - b.getNbVotes())
		return (@track.pop())

	getData: () ->
		queue = []
		@_sort()
		for elem in @tracks
			queue.push(elem.getData());
		return (queue)

	pop: () ->
		@_sort()
		elem = @tracks[0];
		@tracks.splice(0, 1)
		return (elem)


	_sort: () ->
		@tracks.sort((a, b) -> b.getNbVotes() - a.getNbVotes())

	getVotes: (clientId) ->
		res = []
		for elem in @tracks
			if (elem.hasVote(clientId))
				res.push(elem.getUri())
		return res

module.exports = TrackQueue;