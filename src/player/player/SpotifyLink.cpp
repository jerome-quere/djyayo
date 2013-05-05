#include "SpotifyLink.hpp"

namespace Spdj
{
  SpotifyLink::SpotifyLink()
  {
    _link = NULL;
    _loaded = false;
  }

  SpotifyLink::~SpotifyLink()
  {
    if (_link)
      sp_link_release(_link);
    _link = NULL;
  }

  void SpotifyLink::loadFromUri(const std::string& uri)
  {
    if (_link)
      sp_link_release(_link);
    _link = sp_link_create_from_string(uri.c_str());
    _loaded = sp_track_is_loaded(sp_link_as_track(_link));
    if (_loaded)
      loaded(&_link);
  }

  void SpotifyLink::onMetadataUpdate()
  {
    bool old = _loaded;
    _loaded = sp_track_is_loaded(sp_link_as_track(_link));
    if (old != _loaded)
      loaded(&_link);
  }
}
