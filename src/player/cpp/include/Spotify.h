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

#ifndef _SPDJ_SPOTIFY_H_
#define _SPDJ_SPOTIFY_H_

#include <libspotify/api.h>

#include "AudioPlayer.h"
#include "EventEmitter.h"
#include "IOService.h"
#include "SpotifyObject.h"
#include "when/When.h"


namespace SpDj
{
    class Spotify : public EventEmitter
    {
	enum AudioStatus
	    {
		NOT_STARTED,
		PLAYING,
		BUFFER_FLUSHING
	    };

    public:
	Spotify();
	~Spotify();

	When::Promise<bool> login(const std::string& login, const std::string& password);
	When::Promise<SearchResult> search(const std::string& query);
	When::Promise<bool> play(const std::string& link);
	void onPlayerEmpty();

	static void callback_logged_in(sp_session*, sp_error);
	static void callback_notify_main_thread(sp_session *sess);
	static int callback_music_delivery(sp_session *sess, const sp_audioformat *format, const void *frames, int num_frames);
	static void callback_play_token_lost(sp_session *sess);
	static void callback_end_of_track(sp_session *sess);
	static void callback_metadata_updated(sp_session *sess);
	static void callback_search(sp_search*, void*);


	When::Defered<bool> _loginDefer;
	sp_session*	_spSession;
	std::string	_login;
	std::string	_password;
	AudioPlayer	_player;
	AudioStatus	_audioStatus;

	IOService::Event _notifyEvent;
    };
}


#endif
