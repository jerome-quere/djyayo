     /login?method=METHOD&token=TOKEN

This endpoint allow you to get login a user into the system. An access_token will be generated that allow the user to be authentificated for every following request.

### Parameters ###
* **method** *(required)* : The method the should be use to login the user can be either `facebook` or `google`
* **token** *(required)* : A valid facebook or google plus access token.

### Response ###
```json
{
  "access_token": "TOKEN"
}
```

### More information ###
This endpoint will verify the token sent as parameter using the specified method. If the token is valid a new access_token will be generated that can be used to authenticated the user for following requests
