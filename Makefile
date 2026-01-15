DOCK_COMP = docker compose -p inception -f srcs/docker-compose.yml
PATH_VOLUMES = /home/ankammer/data
DOMAIN = ankammer


all: hosts volumes up

hosts:
	@sudo sh -c "cat srcs/requirements/tools/host >> /etc/hosts || true"

volumes:
	@if [ ! -d $(PATH_VOLUMES) ]; then \
		sudo mkdir -p $(PATH_VOLUMES); \
		sudo chown -R root:docker $(PATH_VOLUMES); \
		sudo chmod 711 $(PATH_VOLUMES); \
	fi
	@if [ ! -f /etc/docker/daemon.json ]; then \
		echo '{ "data-root": "$(PATH_VOLUMES)" }' | sudo tee /etc/docker/daemon.json; \
	fi
	@sudo systemctl restart docker

up:
	@$(DOCK_COMP) up --build

down:
	@$(DOCK_COMP) down

logs:
	@$(DOCK_COMP) logs -f

ports:
	@$(DOCK_COMP) ps

clean:
	@$(DOCK_COMP) down --volumes

clean-hosts:
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts

fclean: clean clean-hosts
	@docker system prune -af
	@sudo rm -rf  $(PATH_VOLUMES)

restart:
	@$(DOCK_COMP) down
	@$(DOCK_COMP) up --build --force-recreate

re: fclean all

.PHONY: all hosts volumes up down logs clean fclean clean-hosts restart re ports