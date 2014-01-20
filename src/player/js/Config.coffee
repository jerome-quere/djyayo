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

class Config
	constructor: () ->
		@config = {};
		@config.host = 'localhost';
		@config.port = 4545;
		@config.login = 'YOUR_USER_NAME';
		@config.password = 'YOUR_PASSWORD';
		@config.room = 'defaultRoom';
		@parseArgv()

	parseArgv: () ->
		argv = process.argv;
		i = 1;
		while i + 1 < argv.length
			switch argv[i]
				when "--host" then @config.host = argv[++i]
				when "--port" then @config.port = argv[++i]
				when "--login" then @config.login = argv[++i]
				when "--password" then @config.password = argv[++i]
				when "--room" then @config.room = argv[++i]
				else i++

	get: (name) -> @config[name];

module.exports = new Config()