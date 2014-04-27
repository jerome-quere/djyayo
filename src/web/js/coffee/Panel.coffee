##
# The MIT License (MIT)
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

class Panel
	constructor: (@elem, @wrap) ->
		@visible = false;

	show: () ->
		if @visible == false
			@elem.animate {left: "0px"}, 600, 'swing', () => @wrap.bind('click', @onWrapClick)
			@visible = true

	hide: () ->
		if @visible != false
			@elem.animate({left: "-400px"})
			@visible = false
			@wrap.unbind('click', @onWrapClick)

	toogle: () -> if (@visible == false) then @show() else @hide()

	onWrapClick: () =>
		if @visible == true then @hide();
		return (false);


jQuery.fn.Panel = (conf) ->
	@each () -> jQuery(this).data('panel', new Panel(jQuery(this), jQuery(conf.wrap)))
