FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    wget \
    php-fpm \
    php-mysql \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's/listen = \/run\/php\/php.*-fpm.sock/listen = 9000/g' /etc/php/*/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]