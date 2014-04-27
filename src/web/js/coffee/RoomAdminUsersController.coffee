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

class RoomAdminUsersController
	constructor: (@$scope, $routeParams, locationManager, @room, @user) ->
		@room.enter($routeParams.room).catch () =>
			locationManager.goTo('/roomSelect');

		@room.on 'change', @$scope, @onRoomChange
		@onRoomChange()

		@clearScope();
		@$scope.addAdmin = @addAdmin;
		@$scope.delAdmin = @delAdmin;

	clearScope:	() ->
		@$scope.admins = []
		@$scope.users = []

	onRoomChange:	() =>
		p = @room.getUsers().then (data) =>
			@clearScope();
			for user in data
				user.canRevoke = user.id != @user.getId()
				if (user.isAdmin)
					@$scope.admins.push(user);
				else
					@$scope.users.push(user);
		p.catch () => @clearScope();

	addAdmin: (user) => @room.addAdmin(user.id).then @buildScope;
	delAdmin: (user) => @room.delAdmin(user.id).then @buildScope;

RoomAdminUsersController.$inject = ['$scope', '$routeParams', 'locationManager', 'room', 'user'];
