#!/bin/sh

FILES="coffee/Album.coffee			\
       coffee/Artist.coffee			\
       coffee/HomeController.coffee		\
       coffee/main.coffee			\
       coffee/Model.coffee			\
       coffee/Panel.coffee			\
       coffee/SearchPanelController.coffee	\
       coffee/Spotify.coffee			\
       coffee/Track.coffee			\
       coffee/TrackQueue.coffee			\
       coffee/TrackQueueElement.coffee		\
       coffee/User.coffee			\
       coffee/WebService.coffee"


     coffee -cwj ./script.js $FILES

