#!/bin/bash

set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_FLAG=0
echo "Verification disponibilite MariaDB"
for i in {1..30}; do
    if mysqladmin ping -h mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD --silent; then
        MYSQL_FLAG=1
        break
    fi
    echo "En attente de MariaDB ($i/30)"
    sleep 1
done
if [ $MYSQL_FLAG -eq 0 ]; then
    echo "Erreur: MariaDB indisponible"
    exit 1
fi
sleep 10

chown -R www-data:www-data /var/www/html
cd /var/www/html

if [ ! -f wp-config.php ] || [ ! -f index.php ]; then
    echo "Fichiers Wordpress manquants ou incomplets, nettoyage et installation"
    rm -rf /var/www/html/*
    echo "Wordpress en cours d'installation..."
    readarray -t WP_PASS < /run/secrets/credentials
    IFS=":" read -r WP_ADMIN_USER WP_ADMIN_PASSWORD <<< "${WP_PASS[0]}"
    IFS=":" read -r WP_USER WP_USER_PASSWORD <<< "${WP_PASS[1]}"

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

    echo "Ajout d'un utilisateur supplementaire..."
    if ! wp user get "$WP_USER" --allow-root &>/dev/null; then
        wp user create $WP_USER $WP_USER_EMAIL \
            --role=author \
            --user_pass=$WP_USER_PASSWORD \
            --allow-root
    else
        echo "Utilisateur deja existant"
    fi
else
    echo "Wordpress deja installe"
fi


chown -R www-data:www-data /var/www/html

exec "$@"

# readarray -> lit ligne par ligne et stocke dasn un array -t -> suppr '\n' de fin
# /run/secrets -> dossier de stockage tmp pour les secrets (defini dans docker compose)
# IFS -> Input Field Separator = definit un separator pour recuperer les 2 valeurs distinctes dans read
# <<< -> here string redirige de chaine vers les variable separer par le separator
# www-data -> user et group par defaut
# wp core download -> installe WP
# wp config create -> creer wp-config.php
# wp core install -> creer database par defaut (12 tables)
# wp user create -> creer 2e user comme requis par le sujet