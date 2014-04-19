##
#The MIT License (MIT)
#
# Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##

TEMPLATE	= app
TARGET		= player

QT		= core network

CONFIG		+= no_keywords

SOURCES		+=	src/Application.cpp	    \
			src/AudioData.cpp	    \
			src/AudioFormat.cpp	    \
			src/AudioPlayer.cpp	    \
			src/Command.cpp		    \
			src/Communicator.cpp	    \
			src/Config.cpp		    \
			src/EventEmitter.cpp	    \
			src/gason.cpp		    \
			src/HttpClient.cpp	    \
			src/IOService.cpp	    \
			src/Socket.cpp		    \
			src/Spotify.cpp		    \
			src/SpotifyObject.cpp	    \
			src/main.cpp

HEADERS		+=	include/Application.h	       \
			include/AudioData.h	       \
			include/AudioFormat.h	       \
			include/AudioPlayer.h	       \
			include/CircularBuffer.h       \
			include/CircularBuffer.hpp     \
			include/Command.h	       \
			include/Communicator.h	       \
			include/Config.h	       \
			include/EventEmitter.h	       \
			include/EventEmitter.hpp       \
			include/gason.h		       \
			include/HttpClient.h	       \
			include/IOService.h	       \
			include/Socket.h	       \
			include/Socket.hpp	       \
			include/Spotify.h	       \
			include/SpotifyObject.h	       \
			include/spotifyApiKey.h	       \
			include/Store.h		       \
			include/Store.hpp

INCLUDEPATH	+=	include




*-g++ {
QMAKE_CXXFLAGS+=	-std=c++0x -W -Wall
LIBS		+=	-lspotify -lportaudio
}
win32-msvc* {
LIBS            +=      libspotify.lib portaudio_x86.lib
}
