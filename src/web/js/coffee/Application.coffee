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

class Application extends EventEmmiter

	constructor: () ->
	init: () ->
		@pageElements = jQuery('.page');
		@panelElements = jQuery('.panel');
		@user = new User(this);
		@queue = []
		@initPageControllers()
		@initPanelControllers();
		@server = null
		@currentPage = null
		self = this
		@user.refresh();
		@sammy = Sammy () ->
			@get('#home', () -> self.loadPage('home'))
			@get('#debug', () -> self.loadPage('debug'))
			@get('', () -> self.goToPage('home'))
		@sammy.run();

	initPageControllers : () ->
		@pageControllers = {};
		@pageControllers['home'] = new HomeController(this, @pageElements.filter("#page_home"));
		@pageControllers['debug'] = new DebugController(this, @pageElements.filter("#page_debug"));
		for name, controller of @pageControllers
			ko.applyBindings(controller, @pageElements.filter("#page_#{name}").get(0));

	initPanelControllers: () ->
		@panelControllers = {}
		@panelControllers['search'] = new SearchPanelController(this, @panelElements.filter("#panel_search"));
		for name, controller of @panelControllers
			ko.applyBindings(controller, jQuery("#panel_#{name}").get(0));

	loadPage: (page, params) =>
		if (@currentPage)
			@pageControllers[@currentPage].onUnload();
			$('.page').hide();
		@pageControllers[page].onLoad(params);
		$("#page_#{page}").show();
		@currentPage = page;

	goToPage: (page) =>
		document.location.hash = page;

	getUser: () => return @user;
	updateQueue: (queue) =>
		@queue = queue
		@emit('updateQueue')
	updateCurrentTrack: (track) =>
		@currentTrack = track;
		@emit('updateQueue')

	getQueue: () -> return @queue;
	getCurrentTrack: () -> return @currentTrack;

	ws: (method, data) -> return jQuery.post("/#{method}", JSON.stringify(data), null, 'json')