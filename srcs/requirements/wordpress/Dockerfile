FROM debian:bookworm

RUN apt-get update && apt-get install -y \
        php-fpm \
        php-mysql \
        php-curl \
        php-xml \
        php-mbstring \
        curl \
        && rm -rf /var/lib/apt/lists/* \
        && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        && mv --chmod=755 wp-cli.phar /usr/local/bin/wp \
        && mkdir -p /var/www/html /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

COPY --chmod=755 tools/init.sh /usr/local/bin

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/init.sh" ]

CMD [ "php-fpm8.2", "-F" ]

# Image mentale : WP Chantier - PHP = ouvriers si un outils manque -> certaines taches impossible
        # php-fm -> ecoute le port 9000 (nginx) et exec le code php (moteur)
        # php-mysql -> lien entre WP et mariaDB (requetes sql, connexion DataBase) (telephone)
        # php-curl -> permet a WP d effectuer des requetes http externe (plugins , MAJ ...) (navigateur interne)
        # php-xml -> lit/ecrit XML, requis pour le REST API et parsing xml (lecteur documents)
        # php-mbstring -> gestion UTF (accents, langues etrangere ...) (traducteur)
        # curl -> permet au script de telecharger wp-cli et  explicitement/implicitement WP et wp lui meme utilise dans le code php (telechargeur)