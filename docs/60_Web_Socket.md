The server provide web socket API to get real-time notification of room change. Here how to use it :

### Step 1 ###
Register the web socket to a room by sending this message. If the socket was already associated with a room, the link will be remove.

```json
{
  "name": "command",
  "args": [
    {
      "name":"changeRoom",
      "args": {
        "room":"ROOM_NAME"
      }
    }
  ]
}
```

### Step 2 ###

The server will send you this message when room information need to be updated.

```json
{
  "name": "command",
  "args": [
    {
      "name": "roomChanged"
    }
  ]
}
```