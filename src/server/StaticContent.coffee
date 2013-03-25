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

ChildProcess = require('child_process');
fs = require('fs')

handleRootRequest = (response) ->
	child = ChildProcess.spawn('php', ['src/web/index.php']);
	child.stdout.on 'data', (data) =>
		response.writeBuffer(data)
	child.on 'exit', () =>
		response.end()

handleFileRequest = (request, response) ->
	path = "src/web/#{request.getUrl()}"
	fs.readFile path, (err, data) ->
		if (err)
			response.setCode(404)
			response.end()
		else
			response.enableCache();
			response.writeBuffer(data)
			response.end()

handle = (request, response) ->
	if (request.getUrl() == '/')
		handleRootRequest(response)
	else
		handleFileRequest(request, response)


module.exports.handle = handle;