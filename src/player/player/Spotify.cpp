#include <cstring>
#include <iostream>

#include <Spotify.hpp>

#include "Deferred.hpp"

#include "ApiKey.hpp"

namespace Spdj
{
  Spotify::Spotify()
  {
    sp_error error;

    QObject::connect(this, &Spotify::needToNotify, this, &Spotify::onNeedToNotify, Qt::QueuedConnection);
    QObject::connect(this, &Spotify::metadataUpdated, &_link, &SpotifyLink::onMetadataUpdate);
    QObject::connect(&_link, &SpotifyLink::loaded, this, &Spotify::onLinkLoaded);
    QObject::connect(&_player, &AudioPlayer::endOfTrack, this, &Spotify::endOfTrack);
    initSpStruct();

    error = sp_session_create(&_config, &_session);
    if (SP_ERROR_OK == error)
      std::cout << "SESSION CREATED" << std::endl;
    else
      std::cout << "SESSION FAILED" << std::endl;
  }

  Spotify::~Spotify()
  {
  }

  Df::Promise<bool> Spotify::connect(const std::string& login, const std::string& password)
  {
    Df::Deferred<bool> d;

    _login = login;
    _password = password;
    _loginResolver = d.resolver();
    sp_session_login(_session, _login.c_str(), _password.c_str(), false, NULL);
    return d.promise();
  }

  void Spotify::play(const std::string& url)
  {
    _player.stop();
    _link.loadFromUri(url);
  }

  void Spotify::onNeedToNotify()
  {
    int next;
    sp_session_process_events(_session, &next);
  }

  void Spotify::onLinkLoaded(sp_link** link)
  {
    sp_track* track = sp_link_as_track(*link);
    sp_session_player_unload(_session);
    sp_session_player_load(_session, track);
    sp_session_player_play(_session, true);
  }

  void Spotify::initSpStruct()
  {
    memset(&_config, 0, sizeof(_config));
    _config.api_version = SPOTIFY_API_VERSION;
    _config.cache_location = ".sp";
    _config.settings_location = ".sp";
    _config.application_key = g_appkey;
    _config.application_key_size = g_appkey_size;
    _config.user_agent = "Spotify-DJ";
    _config.callbacks = &_callbacks;
    _config.userdata = this;

    memset(&_callbacks, 0, sizeof(_callbacks));
    _callbacks.logged_in = &Spotify::logged_in;
    _callbacks.logged_out = &Spotify::logged_out;
    _callbacks.metadata_updated = &Spotify::metadata_updated;
    _callbacks.connection_error = &Spotify::connection_error;
    _callbacks.notify_main_thread = &Spotify::notify_main_thread;
    _callbacks.music_delivery = &Spotify::music_delivery;
    _callbacks.play_token_lost = &Spotify::play_token_lost;
    _callbacks.end_of_track = &Spotify::end_of_track;
    _callbacks.log_message = &Spotify::log_message;
  }

  void Spotify::logged_in(sp_session* session, sp_error error)
  {
    Spotify* s =  reinterpret_cast<Spotify*>(sp_session_userdata(session));

    if (error == SP_ERROR_OK)
      s->_loginResolver.resolve(true);
    else
      s->_loginResolver.reject("Spotify login failed");
  }

  void Spotify::logged_out(sp_session*)
  {
  }

  void Spotify::metadata_updated(sp_session* session)
  {
    Spotify* s =  reinterpret_cast<Spotify*>(sp_session_userdata(session));
    s->metadataUpdated();
  }

  void Spotify::connection_error(sp_session*, sp_error)
  {
    std::cout << "CONNECTION ERROR" << std::endl;
  }

  void Spotify::notify_main_thread(sp_session* session)
  {
    Spotify* s =  reinterpret_cast<Spotify*>(sp_session_userdata(session));
    s->needToNotify();
  }

  int  Spotify::music_delivery(sp_session* session, const sp_audioformat* , const void* frames, int nbFrames)
  {
    Spotify* s =  reinterpret_cast<Spotify*>(sp_session_userdata(session));
    s->_player.onMusicDelivery(frames, nbFrames);
    return nbFrames;
  }

  void Spotify::play_token_lost(sp_session*)
  {
  }

  void Spotify::end_of_track(sp_session* session)
  {
    Spotify* s =  reinterpret_cast<Spotify*>(sp_session_userdata(session));
    s->_player.onEndOfTrack();
    sp_session_player_unload(s->_session);
  }

  void Spotify::log_message(sp_session*, const char *)
  {

  }
}
