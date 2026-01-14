DOCK_COMP = docker compose -p inception -f srcs/docker-compose.yml
PATH_VOLUMES = /home/ankammer/data
DOMAIN = ankammer


all: hosts volumes up

hosts:
	@sudo sh -c "cat srcs/requirements/tools/host >> /etc/hosts || true"

volumes:
	@sudo mkdir -p $(PATH_VOLUMES)/mariadb
	@sudo mkdir -p $(PATH_VOLUMES)/wordpress
	@sudo chmod 755 $(PATH_VOLUMES)/mariadb
	@sudo chmod 755 $(PATH_VOLUMES)/wordpress

up:
	@$(DOCK_COMP) up --build

down:
	@$(DOCK_COMP) down

logs:
	@$(DOCK_COMP) logs -f

clean: down
	@$(DOCK_COMP) down --volumes
	@docker system prune -af

clean-hosts:
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts

fclean: clean clean-hosts
	@sudo rm -rf  $(PATH_VOLUMES)/wordpress
	@sudo rm -rf  $(PATH_VOLUMES)/mariadb
	@docker volume rm wordpress_data mariadb_data 2>/dev/null || true

restart:
	@$(DOCK_COMP) down
	@$(DOCK_COMP) up --build --force-recreate

re: fclean all

.PHONY: all hosts volumes up down logs clean fclean clean-hosts restart re