#!/bin/bash

# 1. Warten, bis MariaDB bereit ist
# Wir nutzen die Variablen aus der .env, die Docker an den Container durchreicht
until mysqladmin ping -h"$SQL_HOST" --silent; do
    echo "Warte auf MariaDB..."
    sleep 2
done

# 2. WordPress Installation (nur wenn noch nicht konfiguriert)
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress wird installiert..."
    
    # Kern-Dateien laden
    wp core download --allow-root

    # wp-config.php erstellen
    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=$SQL_HOST

    # Administrator anlegen (Regel: Name darf nicht 'admin' enthalten!)
    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    # Zweiten Benutzer anlegen (Pflicht laut Subjekt)
    wp user create $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root

    # Wichtig: Rechte für den Webserver-User setzen
    chown -R www-data:www-data /var/www/html
    echo "WordPress erfolgreich eingerichtet."
fi

# 3. Vorbereitung für PHP-FPM
mkdir -p /run/php

# 4. Start von PHP-FPM im Vordergrund
# Wir nutzen 'exec', damit PHP zu PID 1 wird (wichtig für Docker Signale)
# Der Pfad /usr/sbin/php-fpm* passt sich an die installierte Version an
echo "Starte PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F