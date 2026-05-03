#!/bin/bash

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe &
    sleep 3

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${SQL_ROOT_PASSWORD}');
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown
fi

exec mysqld_safe
