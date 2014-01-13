/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
 *
 * Permission is hereby granted, free  of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,  including without limitation the rights
 * to use,  copy,  modify,  merge, publish,  distribute, sublicense, and/or sell
 * copies  of  the  Software,  and  to  permit  persons  to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The  above  copyright  notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY  OF ANY KIND, EXPRESS OR
 * IMPLIED,  INCLUDING BUT NOT LIMITED  TO THE  WARRANTIES  OF  MERCHANTABILITY,
 * FITNESS  FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR  ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT  OF  OR  IN  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <sstream>

#include "Spotify.h"
#include "SpotifyObject.h"

#include <iostream>

namespace SpDj
{
    static std::string getLink(sp_link* link) {
	char buf[4096];
	sp_link_as_string(link, buf, 4095);
	return std::string(buf);
    }

    static std::string getLink(sp_track* track) {
	sp_link* link = sp_link_create_from_track(track, 0);
	std::string str = getLink(link);
	sp_link_release(link);
	return str;
    }

    static std::string getLink(sp_artist* artist) {
	sp_link* link = sp_link_create_from_artist(artist);
	std::string str = getLink(link);
	sp_link_release(link);
	return str;
    }

    static std::string getLink(sp_album* album) {
	sp_link* link = sp_link_create_from_album(album);
	std::string str = getLink(link);
	sp_link_release(link);
	return str;
    }

    static std::string escape(const std::string& s) {
	std::string cpy;

	cpy.reserve(s.size());
	for (auto c : s) {
	    if (c == '\"')
		cpy.push_back('\\');
	    cpy.push_back(c);
	}
	return cpy;
    }


    When::Promise<sp_link*> Link::load(Spotify& spotify, const std::string& uri)
    {
	When::Defered<sp_link*> defer = When::defer<sp_link*>();
	sp_link* link = sp_link_create_from_string(uri.c_str());

	if (link == NULL || sp_link_type(link) == SP_LINKTYPE_INVALID) {
	    defer.reject("Link is invalid or can't load it");
	    return defer.promise();
	}
	sp_track* track = sp_link_as_track(link);
	if (sp_track_is_loaded(track))
	    defer.resolve(link);
	else {
	    spotify.on("metadataUpdated", [defer, uri, link, track] () {
		    auto d = defer;
		    if (sp_track_error(track) == SP_ERROR_OK) {
			    d.resolve(link);
			    return false;
		    }
		    else if (sp_track_error(track) == SP_ERROR_OTHER_PERMANENT) {
			d.reject("Link is invalid or can't load it");
			return false;
		    }
		    return true;
		});
	}
	return defer.promise();
    }



    Artist::Artist() {
    }

    Artist::Artist(sp_artist* artist) {
	name = sp_artist_name(artist);
	uri = getLink(artist);
    }


    std::string Artist::toJson() const
    {
	return "{\"name\":\"" + escape(name) + "\", \"uri\":\"" + uri + "\"}";
    }

    Album::Album() {
    }

    Album::Album(sp_album* album) {
	name = sp_album_name(album);
	uri = getLink(album);
    }

    std::string Album::toJson() const
    {
	return "{\"name\":\"" + escape(name) + "\", \"uri\":\"" + uri + "\"}";
    }


    Track::Track() {
    }

    Track::Track(sp_track* track) {
	name = sp_track_name(track);
	uri = getLink(track);
	album = Album(sp_track_album(track));
	artists.resize(1);
	artists[0] = Artist(sp_track_artist(track, 0));
    }

    std::string Track::toJson() const
    {
	std::stringstream ss;
	ss << "{\"name\":\"" << escape(name) << "\", \"uri\":\""  << uri << "\", \"album\":" << album.toJson()
	   << ", \"artists\": [";
	bool first = true;
	for (auto artist : artists) {
	    if (first == false)
		ss << ", ";
	    ss << artist.toJson();
	    first = false;
	}
	ss << "]}";
	return ss.str();
    }

    SearchResult::SearchResult() {
    }

    SearchResult::SearchResult(sp_session* session, sp_search* search) {
	int numTrack = sp_search_num_tracks(search);
	for (int i = 0 ; i < numTrack ; i++) {
	    sp_track* track = sp_search_track (search, i);
	    if (sp_track_get_availability(session, track) != SP_TRACK_AVAILABILITY_AVAILABLE)
		continue;
	    tracks.push_back(Track(track));
	}
    }


    std::string SearchResult::toJson() const {
	std::stringstream ss;

	ss << "{\"tracks\": [";
	bool first = true;
	for (auto track : tracks) {
	    if (first == false)
		ss << ", ";
	    ss << track.toJson();
	    first = false;
	}
	ss << "]}";
	return ss.str();
    }


}
