	/room/:roomName/delAdmin?userID=USERID

This endpoint allow you to delete an admin from the room. You CAN'T revoke your self as a room admin.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.
* **userId** *(required)*: The id of the user you want to revoke as admin in the room.

### Response ###
The response is the same as [room users](room_users)

### Permissions ###
You must be an **admin** of the room to access this endpoint.