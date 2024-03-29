[![CircleCI](https://circleci.com/gh/Sharpz7/vouch/tree/main.svg?style=svg)](https://circleci.com/gh/Sharpz7/vouch/tree/main)

# Vouch

A [Vouch Proxy](https://github.com/vouch/vouch-proxy) setup designed to work with [SharpNet](https://github.com/SharpSet/sharpnet) and [SharpCD](https://github.com/SharpSet/sharpcd)

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

# Install Dependencies

- Make sure [SharpCD](https://github.com/SharpSet/sharpcd) has been installed.

- Create a sharpcd.yml file like the following:

- Ensure the enviromental variables have been set in an enviromental variable file:

```env
# sharpnet ports
HTTP_PORT=80
HTTPS_PORT=443

# Sharpnet gmail login credentials
# for sending errors
MAILPASS=email_password
SENDER_EMAIL=email

# Email that problems will be sent to
RECEIVER_EMAIL=email@domain1.com

# Domain for certificates
DOMAIN=domain2.com

# For Devs only
DEV=FALSE
NETWORK=sharpnet
```

**(See the [sharpnet](https://github.com/Sharpz7/sharpnet) documentation for more information)**

- Run the following command to install vouch proxy:

```bash
sharpcd --remotefile https://raw.githubusercontent.com/Sharpz7/vouch/main/.sharpcd/dependencies.yml
```

# Installation

- Make sure [SharpCD](https://github.com/SharpSet/sharpcd) has been installed.

- Create a sharpcd.yml file like the following:

- Ensure the enviromental variables have been set in an enviromental variable file:

```env
OAUTH_PROVIDER=google
# Set by google
OAUTH_CALLBACK_URLS=${CALLBACK_URL}
OAUTH_CLIENT_ID=${VOUCHID}
OAUTH_CLIENT_SECRET=${VOUCHSECRET}

ADMIN_EMAIL=mygmail@gmail.com
# domain vouch proxy will be hosted on
DOMAINS=mydomain.com
```

- Run the following command to install vouch proxy:

```bash
sharpcd --remotefile https://raw.githubusercontent.com/Sharpz7/vouch/main/.sharpcd/sharpcd.yml
```

- For help with this step, see the [Google Vouch Setup Example](https://github.com/vouch/vouch-proxy/blob/master/config/config.yml_example_google)

## Maintainers

- [Adam McArthur](https://adam.mcaq.me)