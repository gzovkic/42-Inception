FROM debian:bullseye

# Installation von PHP-FPM und Tools (Standard-Paketnamen für Bookworm nutzen) [cite: 86]
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget \
    php-fpm \
    php-mysql \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI installieren [cite: 86]
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# PHP-FPM konfigurieren (Pfad für Bookworm ist /etc/php/8.2/fpm/...) [cite: 132]
# Da die genaue Version variieren kann, nutzen wir einen Platzhalter im Pfad:
RUN sed -i 's/listen = \/run\/php\/php.*-fpm.sock/listen = 9000/g' /etc/php/*/fpm/pool.d/www.conf

# Arbeitsverzeichnis festlegen
WORKDIR /var/www/html

# Setup-Skript kopieren [cite: 81]
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Port für PHP-FPM dokumentieren [cite: 130, 140]
EXPOSE 9000

# Das Skript ausführen [cite: 103]
ENTRYPOINT ["/usr/local/bin/setup.sh"]