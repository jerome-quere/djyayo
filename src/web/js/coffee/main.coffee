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

spotifyDj = angular.module('spotifyDj', [])

spotifyDj.config ['$routeProvider', ($routeProvider) ->
	$routeProvider.when('/home', {templateUrl:"./pages/home.html", controller: HomeController})
	$routeProvider.otherwise({redirectTo: '/home'});
]


spotifyDj.factory 'config', () -> new Config()
spotifyDj.factory 'webService', ($http, $q, config) -> new WebService($http, $q, config)
spotifyDj.factory 'spotify', ($cacheFactory, $q, webService) -> new Spotify($cacheFactory, $q, webService)
spotifyDj.factory 'user', (webService) -> new User(webService)
spotifyDj.factory 'facebook', ($rootScope, $q, config) -> new Facebook($rootScope, $q, config)
spotifyDj.factory 'trackQueue', (webService, spotify, user, $timeout) -> new TrackQueue(webService, spotify, user, $timeout)
spotifyDj.factory 'player', (webService) -> new Player(webService)
spotifyDj.factory 'webSocketClient', ($rootScope, trackQueue, player) -> new WebSocketClient($rootScope, trackQueue, player)


spotifyDj.run (webService, webSocketClient, facebook) ->
	window.webService = webService;