	/room/:roomName/deleteTrack?uri=TRACKURI

This endpoint allow you to remove track from queue.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.
* **uri** *(required)* : The uri of the track you want to remove.

### Response ###
```json
"Success"
```

### Permissions ###
You must be an **admin** of the room to access this endpoint.