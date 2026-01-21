*This project has been created as part
of the 42 curriculum by ankammer*

# Inception

A Docker-based project to deploy a secure, containerized WordPress site with MariaDB and NGINX using Docker Compose.

---

## Features
- Automated setup of WordPress, MariaDB, and NGINX
- Secure credential management via `secrets/` directory
- Custom configuration for each service
- Data persistence using Docker volumes and host folders
- Easy to build, run, and maintain with Makefile automation

---

## Quick Start

### Prerequisites
- Linux (recommended) or macOS
- Docker (20.10+)
- Docker Compose (v2+)
- GNU Make

### Installation & Launch
1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd Inception
   ```
2. **Configure secrets:**
   - Edit files in `secrets/`:
     - `credentials.txt` (WordPress admin, format: username:password)
     - `db_password.txt` (MariaDB user password)
     - `db_root_password.txt` (MariaDB root password)
3. **(Optional) Add local DNS entry:**
   ```sh
   sudo sh -c 'echo "127.0.0.1 ankammer.42.fr" >> /etc/hosts'
   ```
4. **Start the infrastructure:**
   ```sh
   make
   ```

---

## Project Structure

```
Inception/
├── Makefile
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
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
        │   ├── conf/50-server.cnf
        │   └── tools/init.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/init.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/init.sh
        └── tools/host
```

---

## Service Overview
- **NGINX**: Acts as a secure reverse proxy (TLSv1.2/1.3), serves WordPress over HTTPS
- **WordPress**: PHP-FPM-based CMS, fully containerized
- **MariaDB**: Database backend for WordPress

All services are orchestrated via Docker Compose and configured for local development.

---

## Useful Commands
- `make`               : Build and start all services
- `make up`            : (Re)build and start containers
- `make down`          : Stop and remove containers
- `make logs`          : Show logs for all services
- `make ports`         : display the running services and their ports
- `make clean`         : Stop and remove containers and volumes
- `make clean-hosts`   : Cleanup hosts entry
- `make fclean`        : Full cleanup (data, volumes, hosts entry)
- `make restart`       : Restart all containers (force recreate)
- `make re`            : Full rebuild (fclean + all)

---

## Documentation
- [USER_DOC.md](USER_DOC.md): User guide
- [DEV_DOC.md](DEV_DOC.md): Developer documentation

---

## License
This project is for educational purposes.
