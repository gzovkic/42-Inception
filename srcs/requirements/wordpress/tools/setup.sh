#!/bin/bash

until mysqladmin ping -h"$SQL_HOST" --silent; do
    echo "Warte auf MariaDB..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress wird installiert..."
    
    wp core download --allow-root

    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=$SQL_HOST

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    wp user create $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root

   
    chown -R www-data:www-data /var/www/html
    echo "WordPress erfolgreich eingerichtet."
fi

mkdir -p /run/php

echo "Starte PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F