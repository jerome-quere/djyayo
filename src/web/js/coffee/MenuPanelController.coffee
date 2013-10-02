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

class MenuPanelController
	constructor: (@$scope, @webService, @locationManager, @room, @user) ->
		@$scope.user = @user;
		@$scope.room = @room;
		@$scope.logout = @logout;
		@$scope.changeRoom = @changeRoom;
		@$scope.goToTrackQueue = @goToTrackQueue;
		@$scope.goToSearch = @goToSearch;

	logout: () =>
		@user.logout();
		$('#panel_menu').data('panel').hide();

	changeRoom: () =>
		@room.exit();
		@locationManager.goTo('/roomSelect');
		$('#panel_menu').data('panel').hide();

	goToTrackQueue: () =>
		@locationManager.goTo("/room/#{@room.name}");
		$('#panel_menu').data('panel').hide();

	goToSearch: () =>
		@locationManager.goTo("/room/#{@room.name}/search");
		$('#panel_menu').data('panel').hide();


MenuPanelController.$inject = ['$scope', 'webService', 'locationManager', 'room', 'user'];

window.MenuPanelController = MenuPanelController;