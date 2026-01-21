*This project has been created as part
of the 42 curriculum by ankammer*

# Inception


## Description
Inception is a project designed to introduce and deepen your understanding of Docker and containerization. The goal is to deploy a secure, containerized WordPress site with MariaDB and NGINX using Docker Compose. The project emphasizes best practices in service isolation, secrets management, and persistent data storage, all orchestrated through Docker Compose. It is part of the 42 curriculum and aims to provide hands-on experience with modern DevOps tools and concepts.

The infrastructure consists of three main services:
- **NGINX**: Acts as a secure reverse proxy, serving WordPress over HTTPS.
- **WordPress**: A PHP-FPM-based CMS, fully containerized.
- **MariaDB**: The database backend for WordPress.

All services are built from custom Dockerfiles and configured for local development. Secrets and credentials are managed securely, and data is persisted using Docker volumes.

## Instructions

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
2. **Configure secrets:**

   ## Resources

   ### Classic References
   - [Docker Documentation](https://docs.docker.com/)
   - [Docker Compose Documentation](https://docs.docker.com/compose/)
   - [NGINX Documentation](https://nginx.org/en/docs/)
   - [WordPress Documentation](https://wordpress.org/documentation/)
   - [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

   ### AI Usage
   AI (GitHub Copilot, GPT-4.1) was used to assist with:
   - Drafting and refining documentation (README, DEV_DOC, USER_DOC)
   - Generating Dockerfiles and configuration templates
   - Writing and reviewing shell scripts for service initialization
   - Explaining and comparing Docker concepts (networks, volumes, secrets)
   - Providing troubleshooting tips and usage examples

   All code and documentation were reviewed and adapted to meet the specific requirements of the 42 curriculum and the Inception project.

   ---

   ## Documentation
   - [USER_DOC.md](USER_DOC.md): User guide
   - [DEV_DOC.md](DEV_DOC.md): Developer documentation

   ---

   ## License
   This project is for educational purposes.
4. **Start the infrastructure:**
   ```sh
   make
   ```

For more details, see [USER_DOC.md](USER_DOC.md) and [DEV_DOC.md](DEV_DOC.md).


## Features
- Automated setup of WordPress, MariaDB, and NGINX
- Secure credential management via `secrets/` directory
- Custom configuration for each service
- Data persistence using Docker volumes and host folders
- Easy to build, run, and maintain with Makefile automation



## Project Description

This project leverages Docker to create a modular, reproducible, and secure environment for running a WordPress website with a MariaDB backend, all reverse-proxied by NGINX. Each service is built from a custom Dockerfile located in `srcs/requirements/<service>/`, and all orchestration is handled by Docker Compose (`srcs/docker-compose.yml`).

**Main design choices:**
- **Service isolation:** Each component (NGINX, WordPress, MariaDB) runs in its own container for security and maintainability.
- **Secrets management:** Sensitive data (passwords, credentials) are stored in the `secrets/` directory and injected as Docker secrets.
- **Data persistence:** Docker volumes are used to persist database and WordPress data across container restarts.
- **Custom configuration:** Each service is configured via its own config files and initialization scripts.
- **Automation:** The Makefile provides easy commands for setup, build, and cleanup.

**Sources included:**
- Custom Dockerfiles for each service
- Configuration files for NGINX, PHP-FPM, and MariaDB
- Initialization scripts for automated setup
- Docker Compose file for orchestration
- Makefile for automation
- Documentation for users and developers

### Comparison

- **Virtual Machines vs Docker:**
   - *Virtual Machines* virtualize hardware, running full OS instances, which leads to higher resource usage and slower startup times. *Docker* virtualizes at the OS level, sharing the host kernel, resulting in lightweight, fast, and portable containers.
- **Secrets vs Environment Variables:**
   - *Secrets* (Docker secrets) are designed for sensitive data, are not exposed in environment variables, and are mounted as files with restricted permissions. *Environment variables* are easier to use but less secure, as they can be exposed in process lists or logs.
- **Docker Network vs Host Network:**
   - *Docker Network* (bridge or custom) isolates containers from the host and each other, allowing fine-grained control over connectivity. *Host Network* shares the host’s network stack, which can be less secure and is rarely needed for web stacks like this.
- **Docker Volumes vs Bind Mounts:**
   - *Docker Volumes* are managed by Docker, portable, and ideal for persistent data. *Bind Mounts* map host directories directly, useful for development but less portable and harder to manage in production.

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
