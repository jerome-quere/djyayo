#!/bin/sh

FILES="coffee/Album.coffee			\
       coffee/Artist.coffee			\
       coffee/CacheManager.coffee		\
       coffee/Config.coffee			\
       coffee/Facebook.coffee			\
       coffee/Google.coffee			\
       coffee/HeaderController.coffee		\
       coffee/LocationManager.coffee		\
       coffee/LoginController.coffee		\
       coffee/main.coffee			\
       coffee/MenuPanelController.coffee	\
       coffee/Model.coffee			\
       coffee/Panel.coffee			\
       coffee/Player.coffee			\
       coffee/Room.coffee			\
       coffee/RoomSearchController.coffee	\
       coffee/RoomSelectController.coffee	\
       coffee/RoomTrackQueueController.coffee	\
       coffee/Spotify.coffee			\
       coffee/Track.coffee			\
       coffee/TrackQueue.coffee			\
       coffee/TrackQueueElement.coffee		\
       coffee/User.coffee			\
       coffee/WebService.coffee			\
       coffee/WebSocketClient.coffee"


     coffee -cwj ./script.js $FILES

