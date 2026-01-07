# Inception

## Description

Inception est un projet d'administration système qui vise à approfondir les connaissances en virtualisation à travers l'utilisation de Docker. L'objectif principal est de créer une infrastructure complète composée de plusieurs services (NGINX, WordPress, MariaDB) orchestrés via Docker Compose, chacun s'exécutant dans son propre conteneur.

Ce projet permet de comprendre les concepts fondamentaux de la containerisation, de l'orchestration de services, de la gestion des volumes et des réseaux Docker, ainsi que les bonnes pratiques en matière de sécurité et de configuration d'infrastructure.

## Instructions

### Prérequis
- Docker
- Docker Compose
- Make

### Installation et lancement

1. Cloner le dépôt :
```bash
git clone https://github.com/AndyKLB/Inception.git
cd Inception
```

2. Configurer les fichiers de secrets dans le dossier `secrets/` :
   - `credentials.txt` : identifiants WordPress
   - `db_password.txt` : mot de passe de la base de données
   - `db_root_password.txt` : mot de passe root de la base de données

3. Lancer l'infrastructure :
```bash
make
```

4. Accéder aux services :
   - WordPress : https://localhost
   - Adminer (si configuré) : http://localhost:8080

### Commandes disponibles
- `make` : Construire et démarrer tous les conteneurs
- `make stop` : Arrêter les conteneurs
- `make clean` : Arrêter et supprimer les conteneurs
- `make fclean` : Nettoyage complet (conteneurs, volumes, images)
- `make re` : Reconstruction complète

## Description du projet

### Architecture Docker

Le projet utilise Docker pour orchestrer trois services principaux :

1. **NGINX** : Serveur web configuré avec TLSv1.2/TLSv1.3 pour servir WordPress en HTTPS
2. **WordPress + PHP-FPM** : CMS connecté à la base de données MariaDB
3. **MariaDB** : Système de gestion de base de données

Chaque service s'exécute dans un conteneur dédié construit à partir d'une image Alpine ou Debian (avant-dernière version stable). Les conteneurs communiquent via un réseau Docker personnalisé.

### Choix techniques principaux

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|--------|-----------------|---------|
| **Isolation** | Isolation complète au niveau matériel avec OS dédié | Isolation au niveau processus, partage du kernel |
| **Performance** | Plus lourd, nécessite plus de ressources | Léger, démarrage rapide, faible overhead |
| **Portabilité** | Moins portable, dépend de l'hyperviseur | Très portable, fonctionne partout où Docker est installé |
| **Utilisation** | Idéal pour isolation complète et OS différents | Parfait pour microservices et déploiement rapide |

**Choix pour Inception** : Docker est privilégié car il permet une orchestration légère de microservices avec une consommation minimale de ressources.

#### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|--------|---------|----------------------|
| **Sécurité** | Stockage sécurisé, chiffrement possible | Visibles dans les logs et processus |
| **Gestion** | Gérés par Docker Swarm ou outils dédiés | Simples mais exposés |
| **Rotation** | Facilite la rotation des credentials | Nécessite redémarrage des conteneurs |
| **Audit** | Traçabilité des accès | Peu de contrôle |

**Choix pour Inception** : Utilisation de fichiers secrets montés dans `/run/secrets` pour éviter l'exposition de données sensibles dans les variables d'environnement.

#### Docker Network vs Host Network

| Aspect | Docker Network | Host Network |
|--------|---------------|--------------|
| **Isolation** | Réseau isolé pour les conteneurs | Partage direct du réseau de l'hôte |
| **Sécurité** | Meilleure isolation réseau | Exposition directe sur l'hôte |
| **Performance** | Léger overhead NAT | Performance maximale |
| **Flexibilité** | Contrôle fin des communications | Moins de contrôle |

**Choix pour Inception** : Réseau Docker personnalisé (`inception_network`) pour isoler les services tout en permettant leur communication interne sécurisée.

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| **Gestion** | Gérés par Docker, indépendants de l'hôte | Dépendent du système de fichiers hôte |
| **Portabilité** | Plus portables entre environnements | Liés au chemin absolu de l'hôte |
| **Performance** | Optimisés pour Docker | Performance native |
| **Backup** | Facilite les sauvegardes Docker | Nécessite gestion manuelle |

**Choix pour Inception** : 
- **Volumes Docker** pour les données WordPress et MariaDB (persistance et portabilité)
- **Bind Mounts** pour les fichiers de configuration (facilite le développement)

### Structure du projet

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
├──srcs/
   ├── docker-compose.yml          # Orchestration des services
   ├── .env                        # Variables d'environnement
   └── requirements/
       ├── mariadb/
       │   ├── Dockerfile          # Image MariaDB personnalisée
       │   ├── conf/               # Configuration MySQL
       │   └── tools/              # Scripts d'initialisation
       ├── nginx/
       │   ├── Dockerfile          # Image NGINX avec TLS
       │   ├── conf/               # Configuration NGINX et certificats
       │   └── tools/              # Scripts de setup
       └── wordpress/
           ├── Dockerfile          # Image WordPress + PHP-FPM
           ├── conf/               # Configuration PHP
           └── tools/              # Scripts d'installation WP
```

## Resources

### Documentation officielle
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

### Tutoriels et articles
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)

### Utilisation de l'IA

L'intelligence artificielle a été utilisée dans ce projet pour :

1. **Recherche et documentation** : Compréhension des concepts Docker avancés (volumes, réseaux, secrets)
2. **Débogage** : Aide à la résolution de problèmes de configuration et d'erreurs de build
3. **Optimisation** : Suggestions pour améliorer les Dockerfiles et la configuration Docker Compose
4. **Bonnes pratiques** : Validation des choix d'architecture et recommandations de sécurité

**Parties du projet concernées** :
- Configuration initiale de Docker Compose
- Optimisation des Dockerfiles
- Configuration TLS pour NGINX
- Scripts d'initialisation des services
- Rédaction de ce README

**Note** : Tout le code et les configurations ont été revus, testés et adaptés manuellement pour correspondre aux exigences du projet.