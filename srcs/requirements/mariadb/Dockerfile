FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/* && rm -rf /var/lib/mysql/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY --chmod=755 tools/init.sh /usr/local/bin

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/init.sh" ]

CMD [ "mysqld", "--user=mysql" ]

# rm -rf -> 1) supprime cache apt get, 2) l installation de MDB cree une base de donne par defaut qu il faut supprimmer pour que le script puisse creer la sienne