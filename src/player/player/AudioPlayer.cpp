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

#include <iostream>

#include "AudioPlayer.hpp"

namespace Spdj
{
  AudioPlayer::AudioPlayer() :
    _paStream(NULL),
    _endOfTrack(false)
  {
    Pa_Initialize();
  }

  AudioPlayer::~AudioPlayer()
  {
    stop();
    Pa_Terminate();
  }

  void AudioPlayer::onMusicDelivery(const void* frames, int nbFrames)
  {
    if (!_paStream)
      {
	initStream();
	play();
      }
    _endOfTrack = false;
    _stream.write(frames, nbFrames);
  }

  void AudioPlayer::play()
  {
    if (_paStream)
      {
	Pa_StartStream(_paStream);
      }
  }

  void AudioPlayer::pause()
  {
    if (_paStream)
      {
	Pa_StopStream(_paStream);
      }
  }

  void AudioPlayer::stop()
  {
    if (_paStream)
      {
	Pa_CloseStream(_paStream);
	_paStream = NULL;
      }
    _stream.clear();
  }

  void AudioPlayer::onEndOfTrack()
  {
    _endOfTrack = true;
  }

  void AudioPlayer::initStream()
  {
    Pa_OpenDefaultStream(&_paStream,
			 0,
			 2,
			 paInt16,
			 44100,
			 paFramesPerBufferUnspecified,
			 &AudioPlayer::streamCallback,
			 this);
    _stream.setFrameSize(2);
    _stream.setNbChanel(2);
  }

  int AudioPlayer::streamCallback(const void*,
				  void* output,
				  unsigned long frameCount,
				  const PaStreamCallbackTimeInfo* ,
				  PaStreamCallbackFlags,
				  void* obj)
  {
    AudioPlayer* p = static_cast<AudioPlayer*>(obj);
    int size = p->_stream.read(output, frameCount);
    if (size == 0 && p->_endOfTrack)
      {
	p->endOfTrack();
	return (paComplete);
      }
    return (paContinue);
  }


}
