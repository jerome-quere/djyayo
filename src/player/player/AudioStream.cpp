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

#include <cstring>

#include "AudioStream.hpp"

namespace Spdj
{
  AudioStream::AudioStream()
  {
    _buffer.reserve(10000000);
  }

  void AudioStream::clear()
  {
    _buffer.clear();
  }

  size_t AudioStream::write(const void* frames, size_t nbFrame)
  {
    const char* ptr = static_cast<const char*>(frames);
    size_t size = nbFrame * _frameSize * _nbChanel * sizeof(uint8_t);
    _lock.lock();
    _buffer.write(ptr, size);
    _lock.unlock();
    return (nbFrame);
  }

  size_t AudioStream::read(void* frames, size_t nbFrame)
  {
    char* ptr = static_cast<char*>(frames);
    size_t size = nbFrame * _frameSize * _nbChanel * sizeof(uint8_t);
    _lock.lock();
    nbFrame = _buffer.read(ptr, size);
    _lock.unlock();
    memset(ptr + nbFrame, 0, size - nbFrame);
    return (nbFrame);
  }

  void AudioStream::setFrameSize(int frameSize)
  {
    _frameSize = frameSize;
  }

  void AudioStream::setNbChanel(int nbChanel)
  {
    _nbChanel = nbChanel;
  }

  size_t AudioStream::size()
  {
    return (_buffer.size());
  }

};
