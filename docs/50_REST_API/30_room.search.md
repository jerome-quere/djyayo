	/room/:roomName/search?query=QUERY

This endpoint allow you to search for tracks. There MUST be a player connected to the room in order to get results.

### Parameters ###
* **:roomName** *(required)* : The name of the room you want info about.
* **query* *(required)* : The search query.

### Response ###
```json
{
  "tracks": [
    {
      "name": "Slow Down",
      "uri": "spotify:track:3KC5FFplKpLMBCppRmGVpD",
      "imgUrl": "https://d3rt1990lpmkn.cloudfront.net/300/1e0715648a508bcf39a038d6ecf78d558afe86ac",
      "album": {
        "name": "Stars Dance",
        "uri": "spotify:album:4MGDyHLc9ctHHiX4wCn1tV"
      },
      "artists": [
        {
          "name": "Selena Gomez",
          "uri": "spotify:artist:0C8ZW7ezQVs4URX5aX7Kqx"
        }
      ]
    },
    ...
  ]
}
```

### Permissions ###
This endpoint is **public**.