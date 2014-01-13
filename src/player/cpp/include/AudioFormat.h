/*****************************************************************************
 *                                                                           *
 *  This file is part of the project libspotify++.                           *
 *  Made by Jerome Quere < contact@jeromequere.fr >                          *
 *  Created on     11/11/11 17:34:34                                         *
 *  Last update on 11/22/11 22:58:24                                         *
 *                                                                           *
 *****************************************************************************/

#ifndef _SP_AUDIOFORMAT_HPP_
#define _SP_AUDIOFORMAT_HPP_

#include <cstddef>

namespace SpDj
{
  class AudioFormat
  {
  public:

    AudioFormat();
    AudioFormat(int sampleRate, int nbChannels);
    AudioFormat(const AudioFormat& obj);
    AudioFormat& operator=(const AudioFormat& obj);

    int sampleRate() const;
    int nbChannels() const;
    size_t	frameSize() const;

  private:

    int _sampleRate;
    int _nbChannels;
  };
}

#endif
