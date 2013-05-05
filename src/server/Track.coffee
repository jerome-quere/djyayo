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

When = require('when');
Album = require('./Album.coffee');

class Track

	constructor: (@uri) ->
		@name = "";
		@popularity = 0;
		@length = 0
		@album = null;
		@artists = [];

	loadFromSpotifyWs: (data, model) ->
		@name = data.name;
		@popularity = data.popularity;
		@length = data.length;
		promise = model.getAlbum(data.album.href);
		promise = promise.then (album) =>
			@album = album
		for artist in data.artists
			promise2 = model.getArtist(artist.href);
			promise2.then (artist) =>
				@artists.push(artist)
			promise = When.join(promise ,promise2);
		return (promise);

module.exports = Track;