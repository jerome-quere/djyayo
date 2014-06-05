	/room/:roomName/users

This endpoint allow you to get informations about all users that visited the room since it's creation.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.

### Response ###
```json
[
  {
    "id": "USER ID",
    "name": "USER NAME",
    "imgUrl": "USER IMG URL",
    "isAdmin": false
  },
  ...
]
```

### Permissions ###
You must be an **admin** of the room to access this endpoint.