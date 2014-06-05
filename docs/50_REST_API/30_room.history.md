	/room/:roomName/history

This endpoint allow you to get the previously played track in this room.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.

### Response ###
```json
[
  {
    "votes": [
      {
        "id": "google-115556773661403909048"
      }
    ],
    "addedBy": {
      "id": "USERID",
      "name": "USERNAME",
      "imgUrl": "USER IMG URL"
    },
    "track": {
      "name": "Wannabe - Radio Edit",
      "uri": "spotify:track:1Je1IMUlBXcx1Fz0WE7oPT",
      "imgUrl": "https://d3rt1990lpmkn.cloudfront.net/300/5ca35e4b6f956888d8e0ad1a22f36d3bc76c7a49",
      "album": {
        "name": "Spice",
        "uri": "spotify:album:3x2jF7blR6bFHtk4MccsyJ"
      },
      "artists": [
        {
          "name": "Spice Girls",
          "uri": "spotify:artist:0uq5PttqEjj3IH1bzwcrXF"
        }
      ]
    },
    "date": "2014-06-04T17:00:44.081Z"
  },
  ...
]
```

### Permissions ###
This endpoint is **public**.