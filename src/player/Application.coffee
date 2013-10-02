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

CommandGenerator = require('./CommandGenerator.coffee');
Communicator = require("./Communicator.coffee");
Config = require('./Config.coffee')
Player = require('./Player.coffee');
fn = require('when/function');

class Application
	constructor: () ->
		@com = new Communicator()
		@player = new Player();
		@player.on('endOfTrack', @onEndOfTrack);
		@com.on('command', @onCommand);

	run: () ->
		p = @player.connect(Config.get('login'), Config.get('password'))
		p.then () =>
			@com.run()
		p.then null, (err) =>
			console.log(err)

	onPlayCommand: (args) =>
		@player.play(args.uri).then () => CommandGenerator.success();

	onSearchCommand: (args) =>
		return @player.search(args.query).then (res) =>
			return CommandGenerator.success({results: res});

	onEndOfTrack: () => @com.send(CommandGenerator.endOfTrack());

	onCommand: (command) =>
		actions = {}
		actions['play'] = @onPlayCommand;
		actions['search'] = @onSearchCommand;
		if (actions[command.getName()]?)
			promise = fn.call(actions[command.getName()], command.getArgs())
			promise.then (response) => @com.send(response);
			promise.otherwise (e) =>
				if (e.stack) then console.log(e.stack);
				@com.send(CommandGenerator.error());

module.exports = Application