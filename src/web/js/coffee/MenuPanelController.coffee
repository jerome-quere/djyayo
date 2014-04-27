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

class MenuPanelController
	constructor: (@$scope, @locationManager, @room, @user) ->
		@user.on('login', @$scope, @onUserChange)
		@user.on('logout', @$scope, @onUserChange)
		@onUserChange()

		@room.on('enter', @$scope, @onRoomChanged);
		@room.on('exit', @$scope, @onRoomChanged);
		@room.on('change', @$scope, @onRoomChanged);
		@onRoomChanged()

		@$scope.logout = @logout;
		@$scope.changeRoom = @changeRoom;

		@$scope.$on '$locationChangeStart', @closePanel;

	onUserChange: () =>
		@$scope.isLog = @user.isLog();
		@$scope.userName = @user.getName();
		@$scope.userImgUrl = @user.getImgUrl();

	onRoomChanged: () =>
		@$scope.roomName = @room.getName()
		@$scope.isRoomAdmin = @room.isAdmin()

	changeRoom: () =>
		@room.exit();
		@locationManager.goTo('/roomSelect');
		@closePanel()

	logout: () =>
		@user.logout();
		@closePanel();

	closePanel: () ->
		elem = $('#panel_menu')
		if (elem.data('panel')) then elem.data('panel').hide();


MenuPanelController.$inject = ['$scope', 'locationManager', 'room', 'user'];
window.MenuPanelController = MenuPanelController;
