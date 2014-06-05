	/room/:roomName

This endpoint get information about a specific room like :
- **name** : The room name
- **players** : An array with all the players currently connected to the room
- **queue** : An array with all the queued track.
- **admin** : A boolean that indicate if the current user is a room admin or not. You must send a valid access_token or the bolean will alway be false.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.

### Response ###
```json
{
  "name": "ROOM_NAME",
  "players" : [{ "id": ID1}, {"id": ID2}],
  "currentTrack": {
    "votes": [
      {
        "id": "USER ID"
      }
    ],
    "addedBy": {
      "id": "USER ID",
      "name": "USER NAME",
      "imgUrl": "USER IMG URL"
    },
    "track": {
      "name": "Love You Like A Love Song",
      "uri": "spotify:track:4jzktlSihQ5IWBsfQcU8Mo",
      "imgUrl": "https://d3rt1990lpmkn.cloudfront.net/300/f694c5ec82c86b3551ade4c8719d5b4f12ee72a7"
      "album": {
        "name": "When The Sun Goes Down",
        "uri": "spotify:album:0wJklIQzhl7qWBeIO0rZBC"
      },
      "artists": [
        {
          "name": "Selena Gomez & The Scene",
          "uri": "spotify:artist:6dJeKm76NjfXBNTpHmOhfO"
        }
      ]
    }
  },
  "queue": [
    //An array of track with similar infos than currentTrack
  ],
  "admin": false
}
```

### Permissions ###
This endpoint is **public**.