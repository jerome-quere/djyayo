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


class OnVisibleController
	constructor: (@$scope, @$element, @$attrs) ->
		@bind()
		@$element.on('$destroy', () -> @unbind);
		@refresh()

	bind: () =>
		$(window).scroll(@onNeedToRefresh).resize(@onNeedToRefresh)

	unbind: () =>
		$(window).unbind("scroll", @onNeedToRefresh).unbind("resize", @onNeedToRefresh);

	isVisible: () ->
		docViewTop = $(window).scrollTop();
		docViewBottom = docViewTop + $(window).height();
		elemTop = @$element.offset().top;
		elemBottom = elemTop + @$element.height();
		return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));

	onNeedToRefresh: () =>
		@$scope.$apply () =>
			@refresh()

	refresh: () ->
		if (@isVisible())
			@$scope.$eval(@$attrs.onVisible)
			@unbind()


OnVisibleController.$inject = ['$scope', '$element', '$attrs']