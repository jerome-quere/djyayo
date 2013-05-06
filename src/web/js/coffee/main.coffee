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

spotifyDj.factory 'webService', ($http, $q) -> new WebService($http, $q)
spotifyDj.factory 'spotify', ($cacheFactory, $q, webService) -> new Spotify($cacheFactory, $q, webService)
spotifyDj.factory 'user', (webService) -> new User(webService)
spotifyDj.factory 'trackQueue', (webService, spotify, user, $timeout) -> new TrackQueue(webService, spotify, user, $timeout)
spotifyDj.factory 'webSocketClient', (trackQueue) -> new WebSocketClient(trackQueue)

spotifyDj.run (webSocketClient) ->