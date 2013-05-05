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


#ifndef _SDJ_AUDIOPLAYER_HPP_
#define _SDJ_AUDIOPLAYER_HPP_

#include <QObject>

#include <portaudio.h>

#include "AudioStream.hpp"

namespace Spdj
{
  class AudioPlayer : public QObject
  {
    Q_OBJECT;

  public:

    AudioPlayer();
    ~AudioPlayer();

    void play();
    void pause();
    void stop();

    void onMusicDelivery(const void* frames, int nbFrames);
    void onEndOfTrack();


    static int streamCallback(const void *,
			      void *output,
			      unsigned long frameCount,
			      const PaStreamCallbackTimeInfo *timeInfo,
			      PaStreamCallbackFlags statusFlags,
			      void *);

    void initStream();

  signals:
    void endOfTrack();

  private:

    PaStream*   _paStream;
    AudioStream _stream;
    bool _endOfTrack;
  };
}

#endif /* _SDJ_AUDIOPLAYER_HPP_ */
