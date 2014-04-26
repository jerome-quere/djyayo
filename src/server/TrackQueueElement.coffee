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

UserManager = require('./UserManager.coffee');

class TrackQueueElement

	constructor: (@track, userId) ->
		@votes = []
		@addedBy = UserManager.get(userId);

	vote: (userId) ->
		if (@votes.indexOf(userId) == -1)
			@votes.push(userId)

	unvote: (userId) =>
		if ((idx = @votes.indexOf(userId)) != -1)
			@votes.splice(idx, 1);

	getUri: () -> @track.uri

	getNbVotes: () -> @votes.length

	getVotes: () ->
		res = []
		for id in @votes
			res.push({id:id});
		return res

	hasVote: (userId) ->
		return @votes.indexOf(userId) != -1

	getData: () -> {votes: @getVotes(), addedBy: @addedBy.getData(), track: @track}

module.exports = TrackQueueElement;
