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

class TrackQueue
	constructor: (@webService, @spotify, @user, $timeout) ->
		@queue = []
		@currentTrack = {}
		@timeout = $timeout;
		@refresh()
		@user.on('queueChanged', @update);

	refresh: () =>
		p = @webService.query('queue')
		p.then (response) =>
			@update(response.data)
		p.then null, (e) =>
			console.log(e)
		@timeout(@refresh, 5000);

	update: (response) =>
		if response.currentTrack?
			@currentTrack = new TrackQueueElement(@spotify, @user);
			@currentTrack.loadFromWsData(response.currentTrack);
		else
			@currentTrack = null;

		@queue = [];
		for track in response.queue
			elem = new TrackQueueElement(@spotify, @user);
			elem.loadFromWsData(track);
			@queue.push(elem);
