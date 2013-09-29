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

MIMES = {}
MIMES['html'] = 'text/html';
MIMES['css'] = 'text/css';
MIMES['js'] = 'text/javascript'
MIMES['png'] = 'image/png';
MIMES['jpg'] = 'image/jpg';
MIMES['eot'] = 'application/vnd.ms-fontobject';
MIMES['svg'] = 'image/svg+xml';
MIMES['ttf'] = 'application/x-font-ttf';
MIMES['woff'] = 'application/font-woff';


getMIME = (path) ->
	parts = path.split('.');
	ext = parts[parts.length - 1];
	if MIMES[ext]? then return MIMES[ext]
	return MIMES['html']

handleFileRequest = (request, response) ->
	fileName = request.getUrl().split('?')[0]
	if (fileName == '/')
		fileName = 'index.html';
	path = "src/web/#{fileName}"
	fs.readFile path, (err, data) ->
		if (err)
			response.setCode(404)
			response.end(JSON.stringify({code:404, message: "Not Found", data: null}))
		else
			response.enableCache();
			response.setMIME(getMIME(path))
			response.writeBuffer(data)
			response.end()



handle = (request, response) ->
	handleFileRequest(request, response)


module.exports.handle = handle;