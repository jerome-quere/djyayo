/*
 * Copyright 2012 Jerome Quere < contact@jeromequere.com >.
 *
 * This file is part of SpotifyDj.
 *
 * SpotifyDj is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SpotifyDj is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SpotifyDj.If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _SPDJ_SPOTIFY_HPP_
#define _SPDJ_SPOTIFY_HPP_

#include "libspotify/api.h"

#include <QObject>

#include "Deferred.hpp"
#include "Promise.hpp"

#include "AudioPlayer.hpp"
#include "SpotifyLink.hpp"

namespace Spdj
{
  class Spotify : public QObject
  {
    Q_OBJECT;

  public:
    Spotify();
    ~Spotify();

    Df::Promise<bool> connect(const std::string&, const std::string&);
    void play(const std::string& url);

  signals:
    void needToNotify();
    void metadataUpdated();
    void endOfTrack();

  private slots:
    void onNeedToNotify();
    void onLinkLoaded(sp_link**);

  private:

    void	initSpStruct();

    static void logged_in(sp_session*, sp_error);
    static void logged_out(sp_session*);
    static void metadata_updated(sp_session*);
    static void connection_error(sp_session*, sp_error);
    static void notify_main_thread(sp_session*);
    static int  music_delivery(sp_session*, const sp_audioformat *, const void *, int);
    static void play_token_lost(sp_session*);
    static void end_of_track(sp_session*);
    static void log_message(sp_session*, const char *);


    sp_session*			_session;
    struct sp_session_config	_config;
    struct sp_session_callbacks _callbacks;
    Df::Resolver<bool>		_loginResolver;

    SpotifyLink			_link;
    AudioPlayer			_player;

    std::string			_login;
    std::string			_password;
  };
}

#endif /* _SPDJ_SPOTIFY_HPP_ */
