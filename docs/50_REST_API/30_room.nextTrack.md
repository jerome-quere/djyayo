	/room/:roomName/nextTrack

This endpoint allow you to play the next track on the queue. If a track is currently playing it will be stop first.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.

### Response ###
```json
"Success"
```

### Permissions ###
You must be an **admin** of the room to access this endpoint.