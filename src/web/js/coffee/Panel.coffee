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

class Panel
	constructor: (@elem, @wrap) ->
		@visible = false;

	show: () ->
		if (@visible == false)
			@elem.animate {left: "0px"}, 600, 'swing', () =>
				@wrap.bind('click', @onWrapClick); 
			@visible = true;

	hide: () ->
		if (@visible != false)
			@elem.animate({left: "-400px"});
			@visible = false;
			@wrap.unbind('click')

	toogle: () ->
		if (@visible == false)
			@show()
		else
			@hide()

	onWrapClick: () =>
		if (@visible == true)
			@hide();
		return (false);


$ () ->
	$.fn.Panel = (conf) ->
		@each () ->
			jQuery(this).data('panel', new Panel(jQuery(this), $(conf.wrap)))