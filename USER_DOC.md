# Documentation Utilisateur - Inception

*Ce document explique comment utiliser et administrer l'infrastructure Inception.*

## Services fournis

L'infrastructure Inception met à disposition les services suivants :

### 1. **Site WordPress**
- **Description** : Système de gestion de contenu (CMS) permettant de créer et gérer un site web
- **Accès** : https://ankammer.42.fr (ou https://localhost en développement)
- **Fonctionnalités** : 
  - Création et publication d'articles
  - Gestion des médias
  - Personnalisation du thème
  - Extensions et plugins

### 2. **Serveur Web NGINX**
- **Description** : Serveur web sécurisé avec chiffrement TLS
- **Protocoles supportés** : TLSv1.2 et TLSv1.3
- **Fonctionnalité** : Sert le site WordPress de manière sécurisée via HTTPS

### 3. **Base de données MariaDB**
- **Description** : Système de gestion de base de données MySQL
- **Rôle** : Stocke toutes les données WordPress (articles, utilisateurs, configurations)
- **Accès** : Interne uniquement, non exposé publiquement

## Démarrer et arrêter le projet

### Démarrage de l'infrastructure

```bash
make
```

Cette commande va :
1. Construire les images Docker si nécessaire
2. Créer les volumes pour la persistance des données
3. Démarrer tous les services (NGINX, WordPress, MariaDB)

**Temps de démarrage** : Environ 30-60 secondes

### Arrêt de l'infrastructure

```bash
make stop
```

Cette commande arrête tous les conteneurs sans supprimer les données.

### Redémarrage

```bash
make restart
```

Ou :

```bash
make stop
make
```

### Nettoyage complet

⚠️ **Attention** : Cette commande supprime toutes les données !

```bash
make fclean
```

## Accès au site et à l'administration

### Accès au site WordPress

**URL** : https://ankammer.42.fr (ou https://localhost)

Le site est accessible depuis n'importe quel navigateur web. Vous verrez peut-être un avertissement de sécurité concernant le certificat SSL (normal en développement avec un certificat auto-signé).

### Accès au panneau d'administration WordPress

**URL** : https://ankammer.42.fr/wp-admin (ou https://localhost/wp-admin)

**Identifiants par défaut** :
- Les identifiants sont stockés dans le fichier `secrets/credentials.txt`
- Format : `username:password`

### Première connexion

1. Ouvrez votre navigateur
2. Accédez à l'URL du site
3. Ajoutez `/wp-admin` à l'URL pour accéder au panneau d'administration
4. Entrez vos identifiants
5. Vous êtes connecté au tableau de bord WordPress

## Gestion des identifiants

### Localisation des identifiants

Tous les identifiants sensibles sont stockés dans le dossier `secrets/` à la racine du projet :

```
secrets/
├── credentials.txt          # Identifiants WordPress (admin)
├── db_password.txt          # Mot de passe de la base de données
└── db_root_password.txt     # Mot de passe root MariaDB
```

### Format des fichiers

**credentials.txt**
```
username:password
```

**db_password.txt** et **db_root_password.txt**
```
votre_mot_de_passe
```

### Modifier les identifiants

⚠️ **Important** : Les identifiants doivent être modifiés **avant** le premier démarrage.

1. Éditez les fichiers dans `secrets/`
2. Si les conteneurs sont déjà lancés, effectuez un nettoyage complet :
   ```bash
   make fclean
   ```
3. Relancez l'infrastructure :
   ```bash
   make
   ```

### Sécurité des identifiants

- ✅ Ne commitez **jamais** les fichiers de secrets dans Git
- ✅ Utilisez des mots de passe forts (12+ caractères, mixte)
- ✅ Changez les mots de passe par défaut
- ✅ Ne partagez pas vos identifiants

## Vérification du bon fonctionnement

### Vérifier l'état des conteneurs

```bash
docker ps
```

**Résultat attendu** : Vous devez voir 3 conteneurs en cours d'exécution :
- `nginx`
- `wordpress`
- `mariadb`

Exemple de sortie :
```
CONTAINER ID   IMAGE       STATUS         PORTS                   NAMES
abc123def456   nginx       Up 2 minutes   0.0.0.0:443->443/tcp   nginx
789ghi012jkl   wordpress   Up 2 minutes   9000/tcp               wordpress
345mno678pqr   mariadb     Up 2 minutes   3306/tcp               mariadb
```

### Vérifier les logs

Pour voir les logs d'un service spécifique :

```bash
# Logs NGINX
docker logs nginx

# Logs WordPress
docker logs wordpress

# Logs MariaDB
docker logs mariadb
```

### Tester l'accès au site

1. **Test avec curl** :
   ```bash
   curl -k https://localhost
   ```
   Vous devez recevoir du code HTML en réponse.

2. **Test navigateur** :
   - Ouvrez https://ankammer.42.fr
   - La page d'accueil WordPress doit s'afficher

### Vérifier la base de données

```bash
# Connexion à MariaDB
docker exec -it mariadb mysql -u wordpress -p
```

Entrez le mot de passe (contenu de `secrets/db_password.txt`), puis :

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
EXIT;
```

### Vérifier les volumes

```bash
docker volume ls
```

Vous devez voir 2 volumes :
- Volume pour WordPress (`wordpress_data`)
- Volume pour MariaDB (`mariadb_data`)

### Vérifier le réseau

```bash
docker network ls
```

Vous devez voir le réseau `inception_network`.

## Résolution de problèmes courants

### Le site ne répond pas

1. Vérifiez que tous les conteneurs sont lancés : `docker ps`
2. Consultez les logs : `docker logs nginx`
3. Redémarrez l'infrastructure : `make restart`

### Erreur de connexion à la base de données

1. Vérifiez que MariaDB est démarré : `docker ps`
2. Consultez les logs MariaDB : `docker logs mariadb`
3. Vérifiez les mots de passe dans `secrets/`

### Certificat SSL non valide

C'est normal en développement. Le certificat est auto-signé. Pour continuer :
- Chrome/Edge : Cliquez sur "Avancé" puis "Continuer vers le site"
- Firefox : Cliquez sur "Avancé" puis "Accepter le risque et continuer"

### Page blanche WordPress

1. Attendez 1-2 minutes (initialisation en cours)
2. Videz le cache du navigateur
3. Vérifiez les logs WordPress : `docker logs wordpress`

## Sauvegarde et restauration

### Sauvegarder les données

```bash
# Sauvegarder les volumes
docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_backup.tar.gz -C /data .
docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine tar czf /backup/mariadb_backup.tar.gz -C /data .
```

### Restaurer les données

```bash
# Arrêter les conteneurs
make stop

# Restaurer les volumes
docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar xzf /backup/wordpress_backup.tar.gz -C /data
docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine tar xzf /backup/mariadb_backup.tar.gz -C /data

# Redémarrer
make
```

## Support

Pour toute question technique ou problème :
1. Consultez les logs des conteneurs
2. Vérifiez la section "Résolution de problèmes"
3. Référez-vous à la documentation développeur (`DEV_DOC.md`)
