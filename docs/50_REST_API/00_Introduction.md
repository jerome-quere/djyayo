The server provide an HTTP REST API with json based message.

### Protocol ###
The API profive various entry point url that are indivudualy describe in the others pages.
Every response are JSON formated and contain the different field:
- **code** : a response status code describe later
- **message** : a human readable description of the status code
- **data** : the data requested.

The response describes in all the entry points pages match the content of the `data` filed.

#### Response code ####
Here are some of the response code:

* **200** : Success
* **404** : Not found

#### Exemple ####

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    //Data goes here
}
```

#### Security ####
Some actition require the user to be authentified. To login a user must use the `/login` endpoint that generate an access_token that must be used to every requests that require a valid user. The access_token is sent using the query paramer `access_token` (eg. /me?access_token=TOKEN)
