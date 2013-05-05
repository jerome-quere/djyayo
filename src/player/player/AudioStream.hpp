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

#ifndef _SPDJ_AUDIOSTREAM_HPP_
#define _SPDJ_AUDIOSTREAM_HPP_

#include <cstdint>
#include <mutex>

#include "RingBuf.hpp"

namespace Spdj
{
  class AudioStream
  {
  public:
    AudioStream();

    void clear();
    size_t write(const void* frames, size_t nbFrames);
    size_t read(void* frames, size_t nbFrames);
    void setFrameSize(int frameSize);
    void setNbChanel(int nbChanel);
    size_t size();

  private:

    int _frameSize;
    int _nbChanel;
    std::mutex _lock;
    RingBuf	_buffer;
  };
}

#endif
