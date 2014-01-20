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


spotifyDj = angular.module('spotifyDj', ['ngRoute', 'ngCookies'])

spotifyDj.config ['$routeProvider', ($routeProvider) ->
	$routeProvider.when('/login', {templateUrl:"./pages/login.html", controller: LoginController})
	$routeProvider.when('/roomSelect', {templateUrl:"./pages/roomSelect.html", controller: RoomSelectController})
	$routeProvider.when('/room/:room', {templateUrl:"./pages/roomTrackQueue.html", controller: RoomTrackQueueController})
	$routeProvider.when('/room/:room/search', {templateUrl:"./pages/roomSearch.html", controller: RoomSearchController})
	$routeProvider.otherwise({redirectTo: '/roomSelect'});
]

spotifyDj.factory 'config', () -> new Config()
spotifyDj.factory 'webService', ['$http', '$q', 'config', ($http, $q, config) -> new WebService($http, $q, config)]
spotifyDj.factory 'model', ['webService', (webService) -> new Model(webService)]
spotifyDj.factory 'spotify', ['$cacheFactory', '$q', 'webService', ($cacheFactory, $q, webService) -> new Spotify($cacheFactory, $q, webService)]
spotifyDj.factory 'user', ['webService', '$location', '$cookies', (webService, $location, $cookies) -> new User(webService, $location, $cookies)]
spotifyDj.factory 'room', ['webService', 'model', 'user', (webService, model, user) -> new Room(webService, model, user)]
spotifyDj.factory 'locationManager', ['$rootScope', '$location', 'user', ($rootScope, $location, user) -> new LocationManager($rootScope, $location, user)]
spotifyDj.factory 'facebook', ['$rootScope', '$q', 'config', ($rootScope, $q, config) -> new Facebook($rootScope, $q, config)]
spotifyDj.factory 'google', ['$rootScope', '$q', 'config', ($rootScope, $q, config) -> new Google($rootScope, $q, config)]
spotifyDj.factory 'webSocketClient', ['$rootScope', 'config', 'room', ($rootScope, config, room) -> new WebSocketClient($rootScope, config, room)]

spotifyDj.directive 'onVisible', () -> { controller: OnVisibleController}

spotifyDj.run ['webSocketClient', 'locationManager', (w, r) -> ]