/*
 * Copyright 2012 Jerome Quere < contact@jeromequere.com >.
 *
 * This file is part of SpotifyDJ.
 *
 * SpotifyDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SpotifyDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SpotifyDJ.If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _SPDJ_SPOTIFY_LINK_HPP_
#define _SPDJ_SPOTIFY_LINK_HPP_

#include <QObject>

#include <libspotify/api.h>

namespace Spdj
{
  class SpotifyLink : public QObject
  {
    Q_OBJECT;

  public:
    SpotifyLink();
    ~SpotifyLink();

    void loadFromUri(const std::string&);

  signals:
    void loaded(sp_link**);

  public slots:
    void onMetadataUpdate();

  private:
    sp_link*	_link;
    bool        _loaded;

  };
}


#endif /* _SPDJ_SPOTIFY_LINK_HPP_ */
