#!/bin/sh

FILES="coffee/EventEmiter.coffee		\
       coffee/Application.coffee		\
       coffee/CacheManager.coffee		\
       coffee/Controller.coffee			\
       coffee/DebugController.coffee		\
       coffee/HomeController.coffee		\
       coffee/main.coffee			\
       coffee/Model.coffee			\
       coffee/Panel.coffee			\
       coffee/SearchPanelController.coffee	\
       coffee/Spotify.coffee			\
       coffee/User.coffee"


     coffee -cwj ./script.js $FILES
