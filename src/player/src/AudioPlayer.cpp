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

#include "IOService.h"
#include "AudioPlayer.h"

namespace SpDj
{
    const size_t AudioPlayer::minimumBufferSize = 10000000;

    AudioPlayer::AudioPlayer() : _buffer(minimumBufferSize)
    {
	_stream = NULL;
	Pa_Initialize();
    }

    AudioPlayer::~AudioPlayer() {
	Pa_Terminate();
    }

    void AudioPlayer::play(const AudioData& data) {
	if (_stream == NULL)
	    initStream(data.format());
	if (!Pa_IsStreamActive(_stream))
	    Pa_StartStream(_stream);
	std::lock_guard<std::mutex> lock(_mutex);
	_buffer.write((Byte*)data.frames(), (Byte*)data.frames() + (data.nbFrames() * data.format().frameSize()));
    }

    void AudioPlayer::stop()
    {
	_buffer.clear();
	Pa_StopStream(_stream);
    }

    void AudioPlayer::initStream(const AudioFormat& format)
    {
	Pa_OpenDefaultStream(&_stream,
			     0,
			     format.nbChannels(),
			     paInt16,
			     format.sampleRate(),
			     paFramesPerBufferUnspecified,
			     &AudioPlayer::streamCallback,
			     this);
	_audioFormat = format;
    }

    int AudioPlayer::streamCallback(const void*,
				    void* output,
				    unsigned long frameCount,
				    const PaStreamCallbackTimeInfo* ,
				    PaStreamCallbackFlags,
				    void* obj)
    {
	AudioPlayer* p = static_cast<AudioPlayer*>(obj);

	std::lock_guard<std::mutex> lock(p->_mutex);
	auto size = p->_buffer.read((Byte*)output, frameCount * p->_audioFormat.frameSize());
	if (p->_buffer.size() == 0)
	    IOService::addTask([p] {p->emit("empty");});
	std::fill((char*)output + size, (char*)output + frameCount * p->_audioFormat.frameSize(), 0);
	return (paContinue);
    }

}
