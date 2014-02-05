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


#include "HttpClient.h"
#include "gason.h"
#include "Spotify.h"
#include "SpotifyObject.h"
#include "Store.h"

namespace SpDj
{
    static Store<std::string, std::string>& getAlbumImgStore() {
	typedef Store<std::string, std::string> AlbumStore;
	static std::shared_ptr<AlbumStore> store;

	if (!store)
	    store = std::shared_ptr<AlbumStore> (new AlbumStore( [] (const std::string& albumUri) {
			auto p = HttpClient::get("https://embed.spotify.com/oembed/?url="+albumUri);
			auto p2 = p.then([] (const std::string& jsonStr) -> std::string {
				char *endptr, *source = strdup(jsonStr.c_str());
				JsonValue json;
				JsonAllocator allocator;
				JsonParseStatus status = json_parse(source, &endptr, &json, allocator);
				free(source);
				if (status != JSON_PARSE_OK)
				    throw std::runtime_error("Failed to parse JSON");
				for (auto i : json) {
				    if (std::string(i->key) == "thumbnail_url")
					{
					    auto url = std::string(i->value.toString());
					    auto pos = url.find("cover");
					    if (pos != std::string::npos)
						url.erase(pos, 5).insert(pos, "300");
					    return url;
					}
				}
				throw std::runtime_error("Failed to find url in JSON");
			    });
			return p2;
		    }, 1000 * 60 * 30));
	return *store;
    }

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

    When::Promise<Track> Track::build(sp_track* spTrack) {
	Track track;

	track.name = sp_track_name(spTrack);
	track.uri = getLink(spTrack);
	track.albumUri = getLink(sp_track_album(spTrack));
	track.albumName = sp_album_name(sp_track_album(spTrack));
	track.artistName = sp_artist_name(sp_track_artist(spTrack, 0));
	track.artistUri = getLink(sp_track_artist(spTrack, 0));
	return getAlbumImgStore().get(track.albumUri).then([track] (const std::string& url)  {
		auto t = track;
		t.imgUrl = url;
		return t;
	    });
    }

    std::string Track::toJson() const
    {
	std::stringstream ss;
	ss << "{\"name\":\"" << escape(name) << "\", \"uri\":\""  << uri << "\", "
	    << "\"imgUrl\":\"" << escape(imgUrl) << "\","
	   << "\"album\": { \"name\": \"" << escape(albumName) << "\", \"uri\":\"" << albumUri << "\"}"
	   << ", \"artists\": [{\"name\":\"" << escape(artistName) << "\", \"uri\":\"" << artistUri << "\"}]"
	   << "}";
	return ss.str();
    }

    When::Promise<SearchResult> SearchResult::build(sp_session* session, sp_search* search) {
	SearchResult* res = new SearchResult();;

	auto defer = When::defer<SearchResult>();
	std::list<When::Promise<bool> > promises;


	int numTrack = sp_search_num_tracks(search);
	for (int i = 0 ; i < numTrack ; i++) {
	    sp_track* track = sp_search_track (search, i);
	    if (sp_track_get_availability(session, track) != SP_TRACK_AVAILABILITY_AVAILABLE)
		continue;

	    auto p = Track::build(track).then([res] (const Track& t) {
		    res->tracks.push_back(t);
		});
	    promises.push_back(p);
	}
	When::all(promises.begin(), promises.end()).finally([defer, res] () {
		auto d = defer;
		d.resolve(*res);
		delete res;
	    });
	return defer.promise();
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
