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

class SearchPanelController
	constructor: ($scope, @webService, @trackQueue, @user) ->
		@scope = $scope
		@scope.searchInput = ''
		@scope.results = [];
		@scope.search = @search
		@scope.onTrackClick = @onTrackClick;

	search: () =>
		query = @scope.searchInput
		if query.length >= 3
			@webService.query('search', {query: query}).then (httpRes) =>
				res = []
				if httpRes.data.results?
					for track in httpRes.data.results.tracks
						elem = {}
						elem.name = track.name
						elem.artist = {}
						elem.artist.name = track.artists[0].name
						elem.uri = track.uri
						elem.haveMyVote = @user.haveMyVote(track.uri);
						res.push(elem);
				if (query == @scope.searchInput)
					@scope.results.splice(0, @scope.results.length)
					for e in res
						@scope.results.push(e);
		else
			@results = [];
		return (false);

	onTrackClick: (e) =>
		uri = e.uri;
		if (@user.haveMyVote(uri))
			@user.unvote(uri)
			e.haveMyVote = false
		else
			@user.vote(uri);
			e.haveMyVote = true

	show: () ->
		@elem.panel("open")

window.SearchPanelController = SearchPanelController;