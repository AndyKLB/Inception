#!/bin/bash

set -e
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    mysqld --user=mysql --skip-grant-tables &
    sleep 3
    mysql << EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    kill $(pgrep mysqld)
    sleep 2
fi

exec "$@"

# /run/secrets -> dossier de stockage tmp pour les secrets (defini dans docker compose)
# chown necessaire car mysqld s execute avec l user mysql qui n est pas root et doit pouvoir ecrire dans ces fichiers
# if -> verifie si la base de donnee existe sinon il l initialise --user -> qui execute datadir -> ou creer les fichiers
# --skip-grant-tables -> mode special pour exec SQL temporaire sans demarrer completement (pid quelconque) -> '&' = background 
    #commmande SQL:
        # DELETE ... -> supprime les users anonymes (qui pouvaient se connecter sans MDP)
        # DROP ... -> supprime "test" qui est une base accessible a tous et inutile en prod
        # CREATE DATABASE ... -> cree base de donnee si ell n existe pas avec la var env $MYSQL...
        # CREATE USER ... -> cree un user, '@''%' -> depuis n importe quelle ip('@''localhost' -> seulement dans le meme conteneur), identifie par nom et MDP (.env)
        # GRANT ... -> donne tout les droits sur la base a cet user (.env)
        # ALTER ... -> modifie un user, par defaut root n a pas de MDP on lui en attribue un
        # FLUSH ... -> applique tout les changements de droit immediatement (GRANT)
# kill -> kill le processus mysqld tmp (pgrep -> ps | grep)
