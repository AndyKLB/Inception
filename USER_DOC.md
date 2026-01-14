# Inception - User Guide

This guide explains how to use and manage the Inception infrastructure as an end user. It covers setup, service access, credentials, troubleshooting, and backup/restore.

---

## Table of Contents
1. Overview
2. Prerequisites
3. Setup & Startup
4. Accessing Services
5. Managing Credentials
6. Stopping & Cleaning Up
7. Troubleshooting
8. Backup & Restore
9. Support

---

## 1. Overview

Inception provides a local infrastructure with the following services:
- **WordPress**: Website and admin panel (PHP-FPM)
- **NGINX**: Secure web server (HTTPS)
- **MariaDB**: Database backend

All services run in isolated Docker containers and are orchestrated with Docker Compose.

---

## 2. Prerequisites
- Linux (recommended) or macOS
- Docker (20.10+)
- Docker Compose (v2+)
- GNU Make

---

## 3. Setup & Startup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd Inception
   ```
2. **Configure secrets:**
   - Edit files in `secrets/`:
     - `credentials.txt` (format: username:password)
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
   This will build and start all services.

---

## 4. Accessing Services

- **WordPress site:**
  - URL: https://ankammer.42.fr (or https://localhost)
- **WordPress admin panel:**
  - URL: https://ankammer.42.fr/wp-admin (or https://localhost/wp-admin)
  - Credentials: see `secrets/credentials.txt`
- **MariaDB:**
  - Internal only (not exposed to the public)

> You may see a browser warning about the SSL certificate (self-signed in development). Accept the warning to proceed.

---

## 5. Managing Credentials

- All sensitive credentials are stored in the `secrets/` directory.
- **Change credentials before first startup** for security.
- Never commit secrets to version control.
- To update credentials after first run:
  1. Edit the files in `secrets/`
  2. Run:
     ```sh
     make fclean
     make
     ```

---

## 6. Stopping & Cleaning Up

- **Stop all containers:**
  ```sh
  make down
  ```
- **Full cleanup (remove data, volumes, hosts entry):**
  ```sh
  make fclean
  ```

---

## 7. Troubleshooting

- **Check running containers:**
  ```sh
  docker ps
  ```
- **View logs:**
  ```sh
  make logs
  # or for a specific service:
  docker logs <container_name>
  ```
- **Database connection issues:**
  - Check credentials in `secrets/`
  - Ensure MariaDB is running
- **SSL certificate warning:**
  - Normal in development; accept the warning in your browser
- **Site not responding:**
  - Check container status and logs
  - Try restarting:
    ```sh
    make restart
    ```

---

## 8. Backup & Restore

- **Backup WordPress and MariaDB data:**
  ```sh
  docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_backup.tar.gz -C /data .
  docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine tar czf /backup/mariadb_backup.tar.gz -C /data .
  ```
- **Restore data:**
  ```sh
  make down
  docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar xzf /backup/wordpress_backup.tar.gz -C /data
  docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine tar xzf /backup/mariadb_backup.tar.gz -C /data
  make up
  ```

---

## 9. Support

- Check logs and container status for errors
- Review this guide and DEV_DOC.md for troubleshooting
- For further help, contact the project maintainer
