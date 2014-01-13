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

#include <cstring>

#include "AudioData.h"

namespace SpDj
{
  AudioData::AudioData(const void* frames, int nbFrames, const AudioFormat& format) :
    _frames(frames),
    _nbFrames(nbFrames),
    _format(format)
  {
  }


  AudioData::~AudioData()
  {
  }

  const void*	AudioData::frames() const
  {
    return (_frames);
  }

  unsigned int	AudioData::nbFrames() const
  {
    return (_nbFrames);
  }

  const AudioFormat& AudioData::format() const
  {
    return (_format);
  }

}
