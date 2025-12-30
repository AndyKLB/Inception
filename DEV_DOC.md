# Documentation Développeur - Inception

*Ce document explique comment configurer, développer et maintenir l'infrastructure Inception.*

## Table des matières

1. [Configuration initiale](#configuration-initiale)
2. [Build et lancement](#build-et-lancement)
3. [Gestion des conteneurs](#gestion-des-conteneurs)
4. [Persistance des données](#persistance-des-données)
5. [Architecture technique](#architecture-technique)
6. [Développement et modification](#développement-et-modification)

## Configuration initiale

### Prérequis système

- **Docker** : Version 20.10 ou supérieure
  ```bash
  docker --version
  ```

- **Docker Compose** : Version 2.0 ou supérieure
  ```bash
  docker compose version
  ```

- **Make** : GNU Make
  ```bash
  make --version
  ```

- **Système d'exploitation** : Linux (recommandé) ou macOS

### Installation de l'environnement

#### 1. Cloner le dépôt

```bash
git clone https://github.com/AndyKLB/Inception.git
cd Inception
```

#### 2. Configuration du fichier hosts

Ajouter l'entrée DNS locale :

```bash
sudo sh -c 'echo "127.0.0.1 ankammer.42.fr" >> /etc/hosts'
```

Vérifier :
```bash
ping ankammer.42.fr
```

#### 3. Créer les fichiers de secrets

Les fichiers de secrets doivent être créés manuellement et **ne doivent jamais être commités**.

```bash
# Créer le dossier secrets s'il n'existe pas
mkdir -p secrets

# Identifiants WordPress (format: username:password)
echo "admin:VotreMotDePasseSecurise123!" > secrets/credentials.txt

# Mot de passe base de données WordPress
echo "wp_db_password_secure_2024" > secrets/db_password.txt

# Mot de passe root MariaDB
echo "root_password_secure_2024" > secrets/db_root_password.txt

# Sécuriser les permissions
chmod 600 secrets/*
```

#### 4. Configuration du fichier .env

Le fichier `srcs/.env` contient les variables d'environnement :

```bash
# Domaine
DOMAIN_NAME=ankammer.42.fr

# Base de données
DB_NAME=wordpress
DB_USER=wordpress
DB_HOST=mariadb

# WordPress
WP_TITLE=Inception
WP_ADMIN_EMAIL=admin@example.com
WP_URL=https://ankammer.42.fr

# Chemins
WORDPRESS_PATH=/var/www/html
CERTS_PATH=/etc/nginx/ssl
```

**⚠️ Important** : Adapter ces valeurs selon votre configuration.

#### 5. Structure des dossiers

Vérifier que la structure est complète :

```bash
tree -L 3
```

Structure attendue :
```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## Build et lancement

### Utilisation du Makefile

Le `Makefile` centralise toutes les commandes de gestion du projet.

#### Commandes principales

```bash
# Construction et démarrage
make                    # Construit et lance tous les services
make build              # Construit uniquement les images Docker
make up                 # Lance les conteneurs existants
make start              # Alias pour make up

# Arrêt et nettoyage
make stop               # Arrête les conteneurs
make down               # Arrête et supprime les conteneurs
make clean              # Arrête, supprime conteneurs et volumes
make fclean             # Nettoyage complet (conteneurs, volumes, images, réseaux)

# Reconstruction
make re                 # Équivaut à make fclean && make
make rebuild            # Reconstruction sans cache

# Informations et logs
make logs               # Affiche les logs de tous les services
make ps                 # Liste les conteneurs en cours
make status             # Statut des services
```

### Build manuel avec Docker Compose

Si vous préférez utiliser Docker Compose directement :

```bash
cd srcs

# Build
docker compose build

# Lancement
docker compose up -d

# Arrêt
docker compose down

# Avec rebuild
docker compose up -d --build

# Avec suppression des volumes
docker compose down -v
```

### Options de build avancées

#### Build sans cache

Utile après modification des Dockerfiles :

```bash
docker compose build --no-cache
```

#### Build d'un service spécifique

```bash
docker compose build nginx
docker compose build wordpress
docker compose build mariadb
```

#### Build parallèle

```bash
docker compose build --parallel
```

### Vérification du build

```bash
# Vérifier les images créées
docker images | grep inception

# Résultat attendu :
# inception-nginx        latest
# inception-wordpress    latest
# inception-mariadb      latest
```

## Gestion des conteneurs

### Commandes Docker essentielles

#### Lister les conteneurs

```bash
# Conteneurs actifs
docker ps

# Tous les conteneurs (actifs et arrêtés)
docker ps -a

# Avec format personnalisé
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

#### Inspecter un conteneur

```bash
# Inspection complète
docker inspect nginx

# Récupérer l'IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx

# Récupérer les variables d'environnement
docker inspect -f '{{.Config.Env}}' wordpress
```

#### Logs et débogage

```bash
# Logs en temps réel
docker logs -f nginx

# Dernières 100 lignes
docker logs --tail 100 wordpress

# Logs avec timestamps
docker logs -t mariadb

# Logs depuis 10 minutes
docker logs --since 10m nginx
```

#### Exécuter des commandes dans un conteneur

```bash
# Shell interactif
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash

# Commande unique
docker exec nginx ls -la /etc/nginx
docker exec wordpress wp --info --allow-root
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

#### Gestion des ressources

```bash
# Utilisation CPU/RAM
docker stats

# Stats d'un conteneur spécifique
docker stats nginx

# Espace disque utilisé
docker system df

# Informations détaillées
docker system df -v
```

### Gestion des volumes

#### Lister les volumes

```bash
docker volume ls

# Volumes du projet uniquement
docker volume ls | grep inception
```

#### Inspecter un volume

```bash
docker volume inspect wordpress_data
docker volume inspect mariadb_data
```

#### Localisation des données

```bash
# Trouver le point de montage
docker volume inspect wordpress_data | grep Mountpoint

# Exemple de sortie :
# "Mountpoint": "/var/lib/docker/volumes/wordpress_data/_data"
```

#### Sauvegarder un volume

```bash
# Créer une archive du volume
docker run --rm \
  -v wordpress_data:/source:ro \
  -v $(pwd):/backup \
  alpine tar czf /backup/wordpress_backup.tar.gz -C /source .
```

#### Restaurer un volume

```bash
# Restaurer depuis une archive
docker run --rm \
  -v wordpress_data:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/wordpress_backup.tar.gz -C /target
```

#### Nettoyer les volumes orphelins

```bash
# Supprimer les volumes non utilisés
docker volume prune

# Force (sans confirmation)
docker volume prune -f
```

### Gestion du réseau

#### Inspecter le réseau

```bash
docker network inspect inception_network
```

#### Tester la connectivité réseau

```bash
# Depuis WordPress vers MariaDB
docker exec wordpress ping mariadb -c 3

# Depuis NGINX vers WordPress
docker exec nginx ping wordpress -c 3
```

#### Résolution DNS

```bash
# Vérifier la résolution DNS interne
docker exec wordpress nslookup mariadb
docker exec nginx nslookup wordpress
```

## Persistance des données

### Volumes Docker

Le projet utilise deux volumes Docker pour la persistance :

#### 1. Volume WordPress (`wordpress_data`)

**Contenu** :
- Fichiers WordPress (core, thèmes, plugins)
- Uploads (médias, images)
- Configuration wp-config.php

**Point de montage dans le conteneur** : `/var/www/html`

**Localisation physique** :
```bash
docker volume inspect wordpress_data --format '{{.Mountpoint}}'
```

**Accéder aux données** :
```bash
# Lister le contenu
docker run --rm -v wordpress_data:/data alpine ls -la /data

# Copier un fichier depuis le volume
docker cp wordpress:/var/www/html/wp-config.php ./
```

#### 2. Volume MariaDB (`mariadb_data`)

**Contenu** :
- Base de données WordPress
- Tables MySQL
- Logs et caches MariaDB

**Point de montage dans le conteneur** : `/var/lib/mysql`

**Localisation physique** :
```bash
docker volume inspect mariadb_data --format '{{.Mountpoint}}'
```

**Backup de la base de données** :
```bash
# Export SQL
docker exec mariadb mysqldump -u root -p wordpress > backup.sql

# Restauration
docker exec -i mariadb mysql -u root -p wordpress < backup.sql
```

### Bind Mounts

Les fichiers de configuration utilisent des bind mounts pour faciliter le développement :

```yaml
# Configuration NGINX (exemple)
volumes:
  - ./requirements/nginx/conf:/etc/nginx/conf.d:ro
  - ./requirements/nginx/tools:/docker-entrypoint.d:ro
```

**Avantages** :
- Modification en temps réel sans rebuild
- Accès direct depuis l'hôte
- Facilite le debugging

**Localisation** :
- Fichiers de configuration : `srcs/requirements/*/conf/`
- Scripts d'initialisation : `srcs/requirements/*/tools/`

### Cycle de vie des données

#### Au démarrage (`make`)

1. Docker crée les volumes s'ils n'existent pas
2. Les conteneurs montent les volumes
3. Les scripts d'initialisation s'exécutent (première fois uniquement)
4. MariaDB initialise la base si elle n'existe pas
5. WordPress se configure automatiquement

#### À l'arrêt (`make stop`)

- Les conteneurs s'arrêtent
- **Les volumes persistent** (données conservées)

#### Au nettoyage (`make clean`)

- Les conteneurs sont supprimés
- **Les volumes sont supprimés** (perte de données !)

#### À la reconstruction (`make re`)

- Tout est supprimé et reconstruit
- **Perte totale des données**
- Réinitialisation complète

### Stratégies de backup

#### Backup complet automatisé

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup volumes
docker run --rm \
  -v wordpress_data:/source:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar czf /backup/wordpress.tar.gz -C /source .

docker run --rm \
  -v mariadb_data:/source:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar czf /backup/mariadb.tar.gz -C /source .

# Backup SQL
docker exec mariadb mysqldump -u root -p"$(cat secrets/db_root_password.txt)" \
  --all-databases > "$BACKUP_DIR/databases.sql"

echo "Backup créé dans $BACKUP_DIR"
```

#### Restauration

```bash
#!/bin/bash
# restore.sh

BACKUP_DIR=$1

# Arrêter les services
make stop

# Restaurer volumes
docker run --rm \
  -v wordpress_data:/target \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar xzf /backup/wordpress.tar.gz -C /target

docker run --rm \
  -v mariadb_data:/target \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine tar xzf /backup/mariadb.tar.gz -C /target

# Redémarrer
make
```

## Architecture technique

### Schéma d'architecture

```
┌─────────────────────────────────────────────┐
│           Réseau Hôte (Host Network)        │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │   NGINX (Port 443 - HTTPS/TLS)        │ │
│  │   - Reverse Proxy                     │ │
│  │   - SSL/TLS Termination               │ │
│  └───────────────┬───────────────────────┘ │
│                  │                           │
│  ┌───────────────┴───────────────────────┐ │
│  │   Docker Network (inception_network)  │ │
│  │                                       │ │
│  │  ┌──────────────┐  ┌──────────────┐  │ │
│  │  │  WordPress   │  │   MariaDB    │  │ │
│  │  │  + PHP-FPM   ├──┤   Database   │  │ │
│  │  │  (Port 9000) │  │  (Port 3306) │  │ │
│  │  └──────┬───────┘  └──────┬───────┘  │ │
│  │         │                  │          │ │
│  │    ┌────▼─────┐       ┌───▼────┐     │ │
│  │    │ Volume:  │       │ Volume:│     │ │
│  │    │wordpress_│       │mariadb_│     │ │
│  │    │   data   │       │  data  │     │ │
│  │    └──────────┘       └────────┘     │ │
│  └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### Flux de données

1. **Requête HTTPS** → NGINX (port 443)
2. **NGINX** → Déchiffrement TLS
3. **NGINX** → Proxy vers WordPress via FastCGI (port 9000)
4. **WordPress** → Traitement PHP
5. **WordPress** → Requête SQL vers MariaDB (port 3306)
6. **MariaDB** → Retour des données
7. **WordPress** → Génération HTML
8. **NGINX** → Chiffrement TLS
9. **Réponse HTTPS** → Client

### Détails des conteneurs

#### NGINX

```dockerfile
FROM alpine:3.18
# Configuration TLS, reverse proxy FastCGI
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
```

**Rôle** :
- Serveur web frontal
- Terminaison TLS/SSL
- Reverse proxy vers PHP-FPM

**Configuration clé** :
- `/etc/nginx/nginx.conf` : Configuration principale
- `/etc/nginx/ssl/` : Certificats SSL
- FastCGI vers `wordpress:9000`

#### WordPress

```dockerfile
FROM debian:bullseye
# Installation PHP-FPM, WordPress CLI, extensions PHP
EXPOSE 9000
CMD ["php-fpm7.4", "-F"]
```

**Rôle** :
- Moteur PHP-FPM
- Application WordPress
- Interface avec MariaDB

**Configuration clé** :
- `/var/www/html/` : Fichiers WordPress
- `/etc/php/7.4/fpm/` : Configuration PHP-FPM
- Socket FastCGI sur port 9000

#### MariaDB

```dockerfile
FROM debian:bullseye
# Installation MariaDB Server
EXPOSE 3306
CMD ["mysqld"]
```

**Rôle** :
- Serveur de base de données
- Stockage persistant
- Gestion des transactions SQL

**Configuration clé** :
- `/var/lib/mysql/` : Données (volume)
- `/etc/mysql/` : Configuration MariaDB
- Port 3306 (interne uniquement)

## Développement et modification

### Modifier la configuration NGINX

```bash
# Éditer la configuration
vim srcs/requirements/nginx/conf/nginx.conf

# Tester la syntaxe
docker exec nginx nginx -t

# Recharger sans arrêter
docker exec nginx nginx -s reload

# Ou redémarrer le conteneur
docker restart nginx
```

### Modifier WordPress

```bash
# Accéder au conteneur
docker exec -it wordpress bash

# Utiliser WP-CLI
wp plugin list --allow-root
wp theme list --allow-root
wp user list --allow-root

# Installer un plugin
wp plugin install <plugin-name> --activate --allow-root
```

### Modifier MariaDB

```bash
# Accéder à MySQL
docker exec -it mariadb mysql -u root -p

# Commandes SQL utiles
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

### Rebuild après modification Dockerfile

```bash
# Service spécifique
docker compose build --no-cache nginx
docker compose up -d --force-recreate nginx

# Tous les services
make rebuild
```

### Debugging

#### Logs détaillés

```bash
# Activer le mode debug WordPress
docker exec wordpress bash -c "echo \"define('WP_DEBUG', true);\" >> /var/www/html/wp-config.php"

# Voir les logs PHP
docker exec wordpress tail -f /var/log/php7.4-fpm.log
```

#### Vérifier les variables d'environnement

```bash
docker exec wordpress env | grep -E 'DB_|WP_'
docker exec mariadb env | grep MYSQL_
```

#### Test de connectivité

```bash
# Tester MariaDB depuis WordPress
docker exec wordpress mysqladmin ping -h mariadb -u wordpress -p

# Tester PHP-FPM
docker exec nginx curl -I http://wordpress:9000
```

### Bonnes pratiques de développement

1. **Ne jamais modifier directement dans les conteneurs** : Les changements seront perdus au redémarrage
2. **Utiliser les bind mounts** pour les fichiers de configuration
3. **Commiter les Dockerfiles**, pas les secrets
4. **Tester localement** avant de push
5. **Documenter** les changements de configuration
6. **Versionner** les images Docker (tags)

### Variables d'environnement disponibles

Référez-vous au fichier `srcs/.env` pour la liste complète. Principales variables :

```bash
# WordPress
WP_TITLE
WP_ADMIN_EMAIL
WP_URL
WORDPRESS_PATH

# Base de données
DB_NAME
DB_USER
DB_HOST

# Domaine
DOMAIN_NAME
```

## Support et ressources

- **Issues GitHub** : [https://github.com/AndyKLB/Inception/issues](https://github.com/AndyKLB/Inception/issues)
- **Documentation Docker** : [https://docs.docker.com/](https://docs.docker.com/)
- **Documentation WordPress** : [https://developer.wordpress.org/](https://developer.wordpress.org/)
- **Documentation MariaDB** : [https://mariadb.com/kb/](https://mariadb.com/kb/)
