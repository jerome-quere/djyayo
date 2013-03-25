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

class HomeController extends Controller

	constructor: (@app, @elem) ->
		@timer = setInterval(@onTimeout, 5000)
		@onTimeout()
		@queue = ko.computed(@createQueue);

	onTimeout: () =>
		@app.ws('queue').then (data) =>
			@app.updateQueue(data.queue);

	onSearchBtnClick: () ->
		@searchPanel.show();

	onTrackClick: (e) =>
		uri = e.uri;
		if (@app.getUser().haveVote(uri))
			@app.getUser().unvote(uri)
		else
			@app.getUser().vote(uri);

	createQueue: () =>
		res = []
		for elem in @app.getQueue()
			data = {};
			data.uri = elem.uri;
			data.trackName =  if (elem.track?) then elem.track.name else '...' ;
			data.artistName = if (elem.track?) then elem.track.artists[0].name else '...';
			data.imgUrl = if (elem.track?) then Spotify.getImgFromAlbumUrl(elem.track.album.uri) else 'images/album.png';
			data.nbVotes = elem.nbVotes;
			func = () =>
				uri = data.uri
				() => @app.getUser().haveVote(uri)
			func = func();
			data.haveMyVote = ko.computed(func);
			res.push(data);
		return (res);