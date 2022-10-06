#!/bin/sh

# Replace commas with spaces
VOUCH_DOMAINS=$(echo $VOUCH_DOMAINS | sed 's/,/ /g')
sed -i "s/XXXXX/$VOUCH_DOMAINS/g" /sharpnet/nginx.conf

# domain.com becomes VouchCookie_domain_com
VOUCH_COOKIE_NAME=$(echo $VOUCH_COOKIE_NAME | sed 's/\./_/g')
VOUCH_COOKIE_NAME="VouchCookie_$VOUCH_COOKIE_NAME"

/vouch-proxy
