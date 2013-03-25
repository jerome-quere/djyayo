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
	constructor: (@app, @elem) ->
		@searchInput = ko.observable('');
		@results = ko.observableArray();
		@updater = ko.computed(@search);

	search: () =>
		query = @searchInput();
		if query.length >= 3
			@app.ws('search', {query: query}).then (data) =>
				res = []
				if data.results?
					for track in data.results
						elem = {}
						elem.trackName = track.name
						elem.artistName = track.artists[0].name
						elem.uri = track.uri
						func = () =>
							uri = elem.uri
							() => @app.getUser().haveVote(uri)
						func = func();
						elem.haveMyVote = ko.computed(func);
						res.push(elem);
				if (query == @searchInput())
					@results(res.splice(0, 20))
		else
			@results([]);
		return (false);

	onTrackClick: (e) =>
		uri = e.uri;
		if (@app.getUser().haveVote(uri))
			@app.getUser().unvote(uri)
		else
			@app.getUser().vote(uri);

	show: () ->
		@elem.panel("open")