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

class Logger

	constructor: () ->

	debug: (args...) ->
		str = "DEBUG  #{@_getDate()} - #{@_getStr(args)}"
		console.log(str);

	warn: (args...) ->
		str = "WARN   #{@_getDate()} - #{@_getStr(args)}"
		console.log(str);

	error: (args...) ->
		str = "ERROR  #{@_getDate()} - #{@_getStr(args)}"
		console.log(str);

	info: (args...) ->
		str = "INFO   #{@_getDate()} - #{@_getStr(args)}"
		console.log(str);

	_getDate: () ->
		date = new Date()
		str = "#{date.getFullYear()}-#{@_2digits(date.getMonth() + 1)}-#{@_2digits(date.getDate())}"
		str = "#{str} #{@_2digits(date.getHours())}:#{@_2digits(date.getMinutes())}:#{@_2digits(date.getSeconds())}"
		return str;

	_getStr: (args) ->
		str = '';
		for arg in arguments
			str = "#{str}#{arg}"
		return str;

	_2digits: (nb) ->
		if nb >= 10 then return nb
		return "0#{nb}";

logger = new Logger();

module.exports = logger;