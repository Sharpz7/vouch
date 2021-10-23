[![CircleCI](https://circleci.com/gh/Sharpz7/vouch/tree/main.svg?style=svg)](https://circleci.com/gh/Sharpz7/vouch/tree/main)

# Vouch

A [Vouch Proxy](https://github.com/vouch/vouch-proxy) setup designed to work with [SharpNet](https://github.com/Sharpz7/sharpnet) and [SharpCD](https://github.com/Sharpz7/sharpcd)

# Example Nginx Config (Using Sharpnet)

```nginx
server {
    listen 80;
    server_name private.mydomain.com;
    root /var/www/html/;

    # send all requests to the `/validate` endpoint for authorization
    auth_request /validate;

    location = /validate {
	# forward the /validate request to Vouch Proxy
        proxy_pass http://vouch:9090/validate;

        # be sure to pass the original host header
        proxy_set_header Host $http_host;

        # Vouch Proxy only acts on the request headers
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";

        # optionally add X-Vouch-User as returned by Vouch Proxy along with the request
        auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;

        # these return values are used by the @error401 call
        auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
        auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
        auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
    }

    # if validate returns `401 not authorized` then forward the request to the error401block
    error_page 401 = @error401;

    location @error401 {
          # redirect to Vouch Proxy for login
          return 302 https://vouch.mydomain.com/login?url=https://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
    }

    # proxy pass authorized requests to your service
    location / {

        # forward authorized requests to your service protectedapp.yourdomain.com
        proxy_pass http://myprivateapp:8080;

        proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
```

# Installation

- Make sure [SharpCD](https://github.com/Sharpz7/sharpcd) and [SharpNet](https://github.com/Sharpz7/sharpnet) have been installed.

- Create a sharpcd.yml file like the following:

```yml
version: 1

tasks:
  vouch_task:
    name: Vouch Server
    envfile: .env
    type: docker
    sharpurl: https://mydomain.com:5666
    giturl: https://raw.githubusercontent.com/Sharpz7/
    compose: /vouch/main/docker-compose.yml
```

- Ensure the enviromental variables have been set in an enviromental variable file:

```env
OAUTH_PROVIDER=google
# Set by google
OAUTH_CALLBACK_URLS=${CALLBACK_URL}
OAUTH_CLIENT_ID=${VOUCHID}
OAUTH_CLIENT_SECRET=${VOUCHSECRET}

VOUCH_WHITELIST=mygmail@gmail.com
VOUCH_DOMAINS=mydomain.com
```

- Run `sharpcd` to get started!

- For help with this step, see the [Google Vouch Setup Example](https://github.com/vouch/vouch-proxy/blob/master/config/config.yml_example_google)

## Maintainers

- [Adam McArthur](https://adam.mcaq.me)

## TODO

- Remove sharpnet domain and replace to Env var
