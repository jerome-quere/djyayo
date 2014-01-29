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