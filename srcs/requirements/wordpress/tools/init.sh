docker exec -it mariadb mysql -u root#!/bin/bash


chown -R www-data:www-data /var/www/html

cd /var/www/html

if [ ! -f wp-config.php ]; then

    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
    readarray -t WP_PASS < /run/secrets/credentials
    WP_ADMIN_PASSWORD=${WP_PASS[0]}
    WP_USER_PASSWORD=${WP_PASS[1]}

    wp core download --allow-root

    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$MYSQL_HOST

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    wp user create $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root

    chown -R www-data:www-data /var/www/html

fi

exec "$@"

# pas set -e pour avoir des logs de wp wt pouvoir debugger
# readarray -> lit ligne par ligne et stocke dasn un array -t -> suppr '\n' de fin
# /run/secrets -> dossier de stockage tmp pour les secrets (defini dans docker compose)
# www-data -> user et group par defaut
# wp core download -> installe WP
# wp config create -> creer wp-config.php
# wp core install -> creer database par defaut (12 tables)
# wp user create -> creer 2e user comme requis par le sujet