# Inception - Developer Documentation

This document provides technical and practical information for developers working on the Inception project. It covers the project structure, setup, build and deployment process, service architecture, and best practices.

---

## Table of Contents
1. Project Structure
2. Prerequisites
3. Initial Setup
4. Makefile Commands
5. Docker Compose & Service Overview
6. Data Persistence & Secrets
7. Development Workflow
8. Troubleshooting & Tips
9. Resources

---

## 1. Project Structure

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

## 2. Prerequisites

- Linux (recommended) or macOS
- Docker (20.10+)
- Docker Compose (v2+)
- GNU Make

---

## 3. Initial Setup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd Inception
   ```
2. **Create and fill secrets:**
   - `secrets/credentials.txt` (format: username:password)
   - `secrets/db_password.txt` (MariaDB user password)
   - `secrets/db_root_password.txt` (MariaDB root password)
3. **Configure your environment:**
   - Edit `srcs/.env` for domain, DB, and WordPress settings as needed.
4. **(Optional) Add local DNS entry:**
   ```sh
   sudo sh -c 'echo "127.0.0.1 ankammer.42.fr" >> /etc/hosts'
   ```

---

## 4. Makefile Commands

The Makefile automates setup, build, and cleanup. Main targets:

| Command            | Description                                      |
|--------------      |--------------------------------------------------|
| make               | Add hosts, create volumes, build & start all     |
| make hosts         | Add local DNS entry to /etc/hosts                |
| make volumes       | Create local data folders for MariaDB/WordPress  |
| make up            | Build and start all containers                   |
| make down          | Stop and remove all containers                   |
| make logs          | Show logs for all services                       |
| make ports         | display running services and their ports         |
| make clean         | Remove containers, volumes, prune system         |
| make clean-hosts   | Cleanup hosts entry                              |
| make fclean        | Full cleanup: clean + remove data + clean hosts  |
| make restart       | Restart all containers (force recreate)          |
| make re            | Full rebuild (fclean + all)                      |

---

## 5. Docker Compose & Service Overview

All services are defined in `srcs/docker-compose.yml` and built from custom Dockerfiles:

- **nginx**: Serves as a reverse proxy with HTTPS (TLSv1.2/1.3), config in `nginx/conf/nginx.conf`.
- **wordpress**: Runs WordPress with PHP-FPM, config in `wordpress/conf/www.conf`.
- **mariadb**: MariaDB database, config in `mariadb/conf/50-server.cnf`.

Each service has an `init.sh` script for initialization.

**Environment variables** are loaded from `srcs/.env` and passed to containers as needed.

---

## 6. Data Persistence & Secrets

- Data for MariaDB and WordPress is persisted in host folders (see `Makefile` volumes) and/or Docker volumes.
- Secrets (credentials, DB passwords) are stored in the `secrets/` directory and mounted into containers at runtime.
- Never commit secrets to version control.

---

## 7. Development Workflow

1. Edit Dockerfiles, configs, or scripts in `srcs/requirements/*` as needed.
2. Update secrets or `.env` if required.
3. Rebuild and restart services:
   ```sh
   make restart
   # or for a full clean rebuild:
   make re
   ```
4. Check logs:
   ```sh
   make logs
   ```
5. For manual control, use Docker Compose directly in `srcs/`.

---

## 8. Troubleshooting & Tips

- **Check container status:**
  ```sh
  docker ps
  ```
- **View logs for a service:**
  ```sh
  docker logs <container_name>
  ```
- **Database connection issues:**
  - Check secrets and `.env` values
  - Ensure MariaDB is running and healthy
- **Permission issues:**
  - Run make commands with `sudo` if needed for volume or hosts file
- **SSL warnings:**
  - Self-signed certs are used in dev; accept the warning in your browser
- **Full reset:**
  ```sh
  make fclean
  make
  ```

---

## 9. Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

For user instructions, see USER_DOC.md. For project overview, see README.md.
