##
# Copyright 2012 Jerome Quere < contact@jeromequere.com >.
#
# This file is part of SpotifyDj.
#
# SpotifyDj is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpotifyDj is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SpotifyDj.If not, see <http://www.gnu.org/licenses/>.
##

Config = require('./Config.coffee');
EventEmitter = require('events').EventEmitter
lame = require('lame');
Speaker = require('speaker');
Spotify = require('spotify-web');
When = require('when');

class Player extends EventEmitter
	constructor: () ->
		@spotify = null;

	connect: (username, password) ->
		defered = When.defer()
		Spotify.login Config.get('login'), Config.get('password'), (err, spotify) =>
			if (err)
				defered.resolver.reject(err)
			@spotify = spotify
			defered.resolver.resolve(true);
		return defered.promise;

	onEndOfTrack: () => @emit('endOfTrack')

	play: (uri) ->
		@spotify.get uri, (err, track) =>
			if (err) then throw err;
			console.log('Playing: %s - %s', track.artist[0].name, track.name);

			track.play().pipe(new lame.Decoder()).pipe(new Speaker()).on 'finish', () =>
						@onEndOfTrack()

module.exports = Player