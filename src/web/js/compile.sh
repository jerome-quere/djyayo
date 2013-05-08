#!/bin/sh

FILES="coffee/Album.coffee			\
       coffee/Artist.coffee			\
       coffee/Config.coffee			\
       coffee/HomeController.coffee		\
       coffee/main.coffee			\
       coffee/Model.coffee			\
       coffee/Panel.coffee			\
       coffee/Player.coffee			\
       coffee/SearchPanelController.coffee	\
       coffee/Spotify.coffee			\
       coffee/Track.coffee			\
       coffee/TrackQueue.coffee			\
       coffee/TrackQueueElement.coffee		\
       coffee/User.coffee			\
       coffee/WebService.coffee			\
       coffee/WebSocketClient.coffee"


     coffee -cwj ./script.js $FILES

