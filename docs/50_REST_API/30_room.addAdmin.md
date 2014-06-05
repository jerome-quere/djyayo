	/room/:roomName/addAdmin?userID=USERID

This endpoint allow you to add an admin to the room.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.
* **userId** *(required)*: The id of the user you want to promote admin in the room.

### Response ###
The response is the same as [room users](room_users)

### Permissions ###
You must be an **admin** of the room to access this endpoint.