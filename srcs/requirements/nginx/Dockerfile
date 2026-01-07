# telecharge l image de base du conteneur sur dockerhub
FROM debian:bookworm
#   Maj des paquets   instal nginx et ssl (-y == yes to all)    rm le dossier des paquets -> allege
# creer les dossier du certificats ssl et dossier stockage pid pour le surveiller et kill proprement
RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/ssl /var/run/nginx
# Copy script init avec droit exec et conf vers le conteneur
COPY --chmod=755 tools/init.sh /usr/local/bin
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 443
# la commande au runtime "init.sh "nginx", "-g", "daemon off;""
# cmd envoye au script init.sh -> $@ plus flexible que d ecrire en dur dasn le script directement
ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD [ "nginx", "-g", "daemon off;" ]  