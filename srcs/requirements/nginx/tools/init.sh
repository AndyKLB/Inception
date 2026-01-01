#!/bin/bash
# arrete le script immediatement si une commande echoue pour ne pas continuer casse
set -e


if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa: 4096 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IDF/L=PARIS/O=42/CN=ankammer.42.fr"
# il ne genere qu un seul cert et lance nginx
fi
    exec $@
# $@ = "nginx -g daemon off;"


# openssl	Outil de cryptographie
# req	Sous-commande pour les demandes de certificat
# -x509	Génère un certificat auto-signé (pas juste une demande)
# -nodes	Pas de mot de passe sur la clé (no DES encryption)
# -days 365	Certificat valide 365 jours
# -newkey rsa:2048	Crée une nouvelle clé RSA de 2048 bits
# -keyout	Où sauvegarder la clé privée
# -out	Où sauvegarder le certificat
# -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=wzeraig.42.fr"
    # -subj	Fournit les informations du certificat (évite les questions interactives)
    # /C=FR	Country = France
    # /ST=IDF	State = Île-de-France
    # /L=Paris	Locality = Paris
    # /O=42	Organization = 42
    # /CN=ankammer.42.fr	Common Name = nom de domaine (LE PLUS IMPORTANT)
    # But	Remplit les champs du certificat automatiquement