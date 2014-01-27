TEMPLATE        = app
TARGET          = player

QT              = core network

CONFIG          += no_keywords

SOURCES         +=      src/Application.cpp         \
                        src/AudioData.cpp           \
                        src/AudioFormat.cpp         \
                        src/AudioPlayer.cpp         \
                        src/Command.cpp             \
                        src/Communicator.cpp        \
                        src/Config.cpp              \
                        src/EventEmitter.cpp        \
                        src/IOService.cpp           \
                        src/Socket.cpp              \
                        src/Spotify.cpp             \
                        src/SpotifyObject.cpp       \
                        src/main.cpp

HEADERS         +=      include/Application.h          \
                        include/AudioData.h            \
                        include/AudioFormat.h          \
                        include/AudioPlayer.h          \
                        include/CircularBuffer.h       \
                        include/CircularBuffer.hpp     \
                        include/Command.h               \
                        include/Communicator.h          \
                        include/Config.h               \
                        include/EventEmitter.h         \
                        include/EventEmitter.hpp       \
                        include/IOService.h            \
                        include/Socket.h                \
                        include/Socket.hpp             \
                        include/Spotify.h              \
                        include/SpotifyObject.h        \
                        include/main.c                 \
                        include/spotifyApiKey.h        \
                        include/when/Apply.hpp          \
                        include/when/Defered.h         \
                        include/when/Defered.hpp       \
                        include/when/Definition.h      \
                        include/when/LambdaResolver.h  \
                        include/when/Promise.h         \
                        include/when/Promise.hpp       \
                        include/when/When.h            \
                        include/when/When.hpp

INCLUDEPATH     +=      include
LIBS            +=      -lspotify -lportaudio

QMAKE_CXXFLAGS  +=      -std=c++0x -W -Wall
