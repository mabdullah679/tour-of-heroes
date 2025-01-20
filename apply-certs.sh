#!/bin/sh

# Generate or renew SSL certificate
certbot certonly --webroot --webroot-path /usr/share/nginx/html -d aha-fam.duckdns.org --agree-tos --email muhammad.abdullah.0913@gmail.com --non-interactive --expand

# Set up scheduled renewal
echo "0 3 * * * certbot renew --post-hook \"nginx -s reload\"" | crontab -

# Start nginx in the foreground
nginx -g 'daemon off;'
