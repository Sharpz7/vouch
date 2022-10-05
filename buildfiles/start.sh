#!/bin/sh

# Replace commas with spaces
VOUCH_DOMAINS=$(echo $VOUCH_DOMAINS | sed 's/,/ /g')
sed -i "s/XXXXX/$VOUCH_DOMAINS/g" /sharpnet/nginx.conf

/vouch-proxy
