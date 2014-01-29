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

#include "SpotifyObject.h"
#include "Spotify.h"
#include "spotifyApiKey.h"

#include <iostream>
#include <thread>

namespace SpDj
{

    static sp_session_callbacks session_callbacks;
    static sp_session_config spconfig;


    Spotify::Spotify() {
	_loginDefer = When::defer<bool>();

	session_callbacks.logged_in = &Spotify::callback_logged_in;
	session_callbacks.notify_main_thread = &Spotify::callback_notify_main_thread;
	session_callbacks.music_delivery = &Spotify::callback_music_delivery;
	session_callbacks.metadata_updated = &Spotify::callback_metadata_updated;
	session_callbacks.play_token_lost = &Spotify::callback_play_token_lost;
	session_callbacks.log_message = NULL;
	session_callbacks.end_of_track = &Spotify::callback_end_of_track;


	spconfig.api_version = SPOTIFY_API_VERSION;
	spconfig.cache_location = "tmp";
	spconfig.settings_location = "tmp";
	spconfig.application_key = g_appkey;
	spconfig.application_key_size = g_appkey_size;
	spconfig.user_agent = "spotify-jukebox-example";
	spconfig.callbacks = &session_callbacks;
	spconfig.userdata = NULL;
	spconfig.userdata = this;


	_audioStatus = NOT_STARTED;

	sp_error err = sp_session_create(&spconfig, & _spSession);
	if (SP_ERROR_OK != err)
	    throw std::runtime_error("Unable to create session:" + std::string(sp_error_message(err)));

	_player.on("empty", [this] () { onPlayerEmpty(); });
    }


    Spotify::~Spotify()
    {
	sp_session_release(_spSession);
	_notifyEvent.cancel();
    }

    When::Promise<bool> Spotify::login(const std::string& login, const std::string& password) {
	_login = login;
	_password = password;
	sp_session_login(_spSession, _login.c_str(), password.c_str(), 0, NULL);
	return _loginDefer.promise();
    }

    When::Promise<SearchResult> Spotify::search(const std::string& query) {
	When::Defered<SearchResult> defer = When::defer<SearchResult>();

	std::string* q = new std::string(query);
	std::function<void (sp_search*)>* f = new std::function<void (sp_search*)>([this, defer, q] (sp_search* s) {
		auto d2 = defer;
		d2.resolve(SearchResult::build(_spSession, s));
		delete q;
		sp_search_release(s);
	    });
	sp_search_create(_spSession, q->c_str(), 0, 50, 0, 50, 0, 50, 0, 0,
			 (sp_search_type)0, Spotify::callback_search, f);
	return defer.promise();
    }

    When::Promise<bool> Spotify::play(const std::string& uri) {
	auto  p = Link::load(*this, uri);

	return p.then([this] (sp_link* link) -> bool {
		sp_track* track = sp_link_as_track(link);

		if (sp_session_player_load(_spSession, track) != SP_ERROR_OK)
		    throw std::runtime_error("Can't load link in player");
		if (sp_session_player_play(_spSession, true) != SP_ERROR_OK)
		    throw std::runtime_error("Can't start player");
		_audioStatus = PLAYING;
		return true;
	    });
    }

    When::Promise<Track> Spotify::lookupTrack(const std::string& uri) {
	auto  p = Link::load(*this, uri);

	return p.then([this] (sp_link* link) {
		sp_track* track = sp_link_as_track(link);
		return Track::build(track);
	    });
    }

    void Spotify::onPlayerEmpty() {
	if (_audioStatus == BUFFER_FLUSHING) {
	    _player.stop();
	    _audioStatus = NOT_STARTED;
	    emit("endOfTrack");
	}
    }

    void Spotify::callback_logged_in(sp_session* s, sp_error err) {
	Spotify* spotify = reinterpret_cast<Spotify*>(sp_session_userdata(s));
	if (SP_ERROR_OK != err)
	    spotify->_loginDefer.reject("Spotify: Login failed:"+std::string(sp_error_message(err)));
	else
	    spotify->_loginDefer.resolve(true);
    }

    void Spotify::callback_notify_main_thread(sp_session* s) {
	Spotify* spotify = reinterpret_cast<Spotify*>(sp_session_userdata(s));

	IOService::addTask([s, spotify] () {
		int next_timeout;
		sp_session_process_events(s, &next_timeout);

		if (next_timeout != 0) {
		    auto event = IOService::addTimer(next_timeout, [s] () {Spotify::callback_notify_main_thread(s);});

		    spotify->_notifyEvent.cancel();
		    spotify->_notifyEvent = event;
		}
	    });
    }

    int Spotify::callback_music_delivery(sp_session * s, const sp_audioformat* format, const void* frames, int nbFrames) {
	Spotify* spotify = reinterpret_cast<Spotify*>(sp_session_userdata(s));

	AudioData data(frames, nbFrames, AudioFormat(format->sample_rate, format->channels));
	spotify->_player.play(data);
	return nbFrames;
    }

    void Spotify::callback_play_token_lost(sp_session *) {

    }

    void Spotify::callback_end_of_track(sp_session* s) {
	Spotify* spotify = reinterpret_cast<Spotify*>(sp_session_userdata(s));
	sp_session_player_unload(spotify->_spSession);
	spotify->_audioStatus = BUFFER_FLUSHING;
    }

    void Spotify::callback_metadata_updated(sp_session *s) {
	Spotify* spotify = reinterpret_cast<Spotify*>(sp_session_userdata(s));
	IOService::addTask([spotify] () {
		spotify->emit("metadataUpdated");
	    });
    }

    void Spotify::callback_search(sp_search*s, void* data) {
	std::function<void (sp_search*)>* f = reinterpret_cast<std::function<void (sp_search*)>*>(data);
	f->operator()(s);
	delete f;
    }
}
