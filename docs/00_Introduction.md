**Dj Yayo** is a modern jukebox that let you share music with everyone around you.

This project is composed of three different part.

## Project Organisation ##

### Server ###
This part handle the room an trak system. It provide an REST HTTP API that allow other application to get information about room players or tracks.

### Web application ###
This is the GUI of the project. It's a web application that use the server REST API to access room information and allow user to search and vote tracks.

### Player ###
This part is handling  the link between music provider and the server. Il allow to play, search and get informations from track using for exemple the spotify API.