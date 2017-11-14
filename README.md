# Clean-up service

This microservice deletes old data from the database. It provides one call, clean.

The service uses the [mu-semtech/mu-ruby-template:2.3.0-ruby2.3](https://github.com/mu-semtech/mu-ruby-template).

The responses are based on [JSON API](http://jsonapi.org).

## config.json

The service uses one configuration file, config.json.

### prefixes

The backend supports by default the following prefix:
```
mu: <http://mu.semte.ch/vocabularies/core/>
```

However, you can specify your own prefixes (which will override the default one(s)) in the config.json file.
```
{
    "queries": {
        ...
    },
    "prefixes" : ["PREFIX mu: <http://mu.semte.ch/vocabularies/core/>", "PREFIX foo: <http://foo.bar/>"]
}
```

### query options

The backend fetches the delete queries by keys. The values are always in an array. This way you can add more than one delete query to one key.

If you want to delete only results before today's date, then add the `change_the_date` into your query. The backend will switch that to today's date in YYYY-mm-dd format.

If you want to pass a graph uuid, then add the `change_graph_uuid` into your query, and pass the wanted uuid in the url with `graph` parameter.

### example

```json
{
    "queries": {
        "type1": [
            "delete { ?collection ?a ?b. } where { ?collection a <http://mu.semte.ch/vocabularies/core/validationResultCollection> ; ?a ?b. filter not exists{?collection mu:timestamp 'change_the_date'^^xsd:dateTime} }",
            "delete { ?result ?a ?b. } where { ?result a <http://mu.semte.ch/vocabularies/core/validationResult>; ?a ?b. filter not exists{?randomCollection mu:hasResult ?result.} }",
            "delete { ?graph ?a ?b. } where { ?graph a esco:Graph ; mu:uuid change_graph_uuid; ?a ?b. }"
        ]
    }
}

```

## /cleanup/clean?delete=type1,type2

This call deletes data from the database depending on the delete parameter. The delete parameter is mandatory. This parameter contains what kind of data should be deleted. The selected types have to be in the url after the `?delete=`, separated by commas, and no spaces are allowed. If the type doesn't exist in the config.json, the backend will skip it.

If you have a rule, where you want to pass a graph uuid, you have to use the `graph=` parameter.

The current types can be found in the config/delete_queries.json file.

Because this is a DELETE call, we have to add `-X DELETE` to the curl call. 

### example call #1
`curl -v -X DELETE http://localhost:500/cleanup/clean?delete=validations,validationResult`

`curl -v -X DELETE "http://localhost:502/clean?delete=import&graph=randomuuid"`

### example response #1
The backend will return with status 200 and a small message in the metadata telling what happened.
```
* Connected to localhost (127.0.0.1) port 500 (#0)
> DELETE /cleanup/clean?delete=validations,validationResult HTTP/1.1
> Host: localhost:500
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Length: 0
>
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0< HTTP/1.1 200 OK
< Content-Type: application/vnd.api+json
< Content-Length: 116
< X-Content-Type-Options: nosniff
< Server: WEBrick/1.3.1 (Ruby/2.3.1/2016-04-26)
< Date: Tue, 06 Sep 2016 13:11:13 GMT
< Connection: Keep-Alive
<
{ [116 bytes data]
100   116  100   116    0     0     54      0  0:00:02  0:00:02 --:--:--    54
* Connection #0 to host localhost left intact
```
```json
{
  "meta": {
    "message": "Previous validation collections and results were deleted. Validationresult data was deleted. "
  }
}

```
### example calls #2
`curl -v -X DELETE -H "Content-Length: 0" http://localhost:500/cleanup/clean`

`curl -v -X DELETE -H "Content-Length: 0" http://localhost:500/cleanup/clean?random=type1`

`curl -v -X DELETE -H "Content-Length: 0" http://localhost:500/cleanup/clean?delete=`

### example response #2
The calls above give the same 404 result.
```
* Connected to localhost (127.0.0.1) port 500 (#0)
> DELETE /cleanup/clean HTTP/1.1
> Host: localhost:500
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Length: 0
>
< HTTP/1.1 404 Not Found
< Content-Type: application/vnd.api+json
< Content-Length: 60
< X-Content-Type-Options: nosniff
< Server: WEBrick/1.3.1 (Ruby/2.3.1/2016-04-26)
< Date: Tue, 06 Sep 2016 13:15:17 GMT
< Connection: Keep-Alive
<
{ [60 bytes data]
100    60  100    60    0     0   4481      0 --:--:-- --:--:-- --:--:--  4615
* Connection #0 to host localhost left intact

```
```json
{
  "errors": [
    {
      "title": "Missing or empty 'delete' parameter"
    }
  ]
}


```

## How to run the clean-up-microservice

- Use the following command from the clean-up-microservice folder. You have to add the port, the name of your database and the path to your code!

- You can add the config file location via the `CONFIG_DIR_CLEANUP` environment variable, or you can mount a `/config` folder, that contains your file.

- If your database is running in another docker compose, you can use the `--network` to connect to it, example: `--network etmsplatform_default`

### Build

```
docker build -t clean-up-service:latest .
```

### Running development environment

```
docker run -it --rm -p 80:80 --name clean_service \
    -e RACK_ENV=development \
    -v "$PWD":/app \
    -v "$PWD"/example:/config \
    --link your_db:database \
    clean-up-service
```

### Running production environment

```
docker run -p 80:80 --name clean_service \
    -v <PATH_TO_YOUR_PRODUCTION_CONFIG>:/config \
    --link your_db:database \
    clean-up-service
```
