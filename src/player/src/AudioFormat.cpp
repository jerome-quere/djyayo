/*
 * Copyright 2012 Jerome Quere < contact@jeromequere.com >.
 *
 * This file is part of libspotify++.
 *
 * libspotify++ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * libspotify++ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with libspotify++.If not, see <http://www.gnu.org/licenses/>.
 */

#include "AudioFormat.h"
#include <cstdint>


namespace SpDj
{
  AudioFormat::AudioFormat() :
    _sampleRate(0),
    _nbChannels(0)
  {
  }

  AudioFormat::AudioFormat(int sampleRate, int nbChannels) :
    _sampleRate(sampleRate),
    _nbChannels(nbChannels)
  {
  }

  AudioFormat::AudioFormat(const AudioFormat& obj)
  {
    operator=(obj);
  }

  AudioFormat& AudioFormat::operator=(const AudioFormat& obj)
  {
    _sampleRate = obj._sampleRate;
    _nbChannels = obj._nbChannels;
    return (*this);
  }

  int AudioFormat::sampleRate() const
  {
    return _sampleRate;
  }

  int AudioFormat::nbChannels() const
  {
    return _nbChannels;
  }

  size_t	AudioFormat::frameSize() const
  {
    return (sizeof(int16_t) * _nbChannels);
  }

}
