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


app = angular.module('app', ['ngRoute', 'ngCookies', 'ui.bootstrap'])

app.config ['$locationProvider', '$routeProvider', ($locationProvider, $routeProvider) ->
	$routeProvider.when('/login', {templateUrl:"./pages/login.html", controller: LoginController})
	$routeProvider.when('/roomSelect', {templateUrl:"./pages/roomSelect.html", controller: RoomSelectController})
	$routeProvider.when('/roomCreate', {templateUrl:"./pages/roomCreate.html", controller: RoomCreateController})
	$routeProvider.when('/room/:room', {templateUrl:"./pages/roomTrackQueue.html", controller: RoomTrackQueueController})
	$routeProvider.when('/room/:room/history', {templateUrl:"./pages/roomHistory.html", controller: RoomHistoryController})
	$routeProvider.when('/room/:room/search', {templateUrl:"./pages/roomSearch.html", controller: RoomSearchController})
	$routeProvider.when('/room/:room/admin/trackQueue', {templateUrl:"./pages/roomAdminTrackQueue.html", controller: RoomAdminTrackQueueController})
	$routeProvider.when('/room/:room/admin/users', {templateUrl:"./pages/roomAdminUsers.html", controller: RoomAdminUsersController})
	$routeProvider.otherwise({redirectTo: '/roomSelect'});
	$locationProvider.html5Mode(true);
]

app.factory 'config', () -> new ConfigServiceController()
app.factory 'loading', () -> new LoadingServiceController()
app.factory 'webService', ['$http', '$q', 'config', ($http, $q, config) -> new WebServiceServiceController($http, $q, config)]
app.factory 'user', ['webService', '$location', '$cookies', (webService, $location, $cookies) -> new UserServiceController(webService, $location, $cookies)]
app.factory 'room', ['webService', 'user', (webService, user) -> new RoomServiceController(webService, user)]
app.factory 'locationManager', ['$rootScope', '$location', 'user', ($rootScope, $location, user) -> new LocationManagerServiceController($rootScope, $location, user)]
app.factory 'facebook', ['$rootScope', '$q', 'config', ($rootScope, $q, config) -> new FacebookServiceController($rootScope, $q, config)]
app.factory 'google', ['$rootScope', '$q', 'config', ($rootScope, $q, config) -> new GoogleServiceController($rootScope, $q, config)]
app.factory 'webSocketClient', ['$rootScope', 'config', 'room', ($rootScope, config, room) -> new WebSocketClientServiceController($rootScope, config, room)]

app.directive 'onVisible', () -> OnVisibleDirectiveController.getConfig()

app.run ['webSocketClient', 'locationManager', (w, r) -> ]
