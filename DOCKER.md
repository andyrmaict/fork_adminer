# Adminer Docker Setup

This directory contains Docker configuration files to run Adminer in a containerized environment.

## Quick Start

1. **Build and run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

2. **Access Adminer:**
   - **Main Interface:** `http://localhost:8060/adminer/`
   - **Editor Interface:** `http://localhost:8060/editor/`
   - **Home Page:** `http://localhost:8060` (redirects to adminer)

3. **Stop the service:**
   ```bash
   docker-compose down
   ```

## Alternative: Build and run manually

1. **Build the Docker image:**
   ```bash
   docker build -t adminer-app .
   ```

2. **Run the container:**
   ```bash
   docker run -d -p 8060:80 --name adminer adminer-app
   ```

## Configuration

### Port Mapping
- **Host Port:** 8060
- **Container Port:** 80
- **Access URLs:** 
  - Main: http://localhost:8060/adminer/
  - Editor: http://localhost:8060/editor/

### Database Connections

The Docker setup includes optional database services that you can uncomment in `docker-compose.yml`:

#### MySQL Example:
- **Host:** mysql (container name)
- **Port:** 3306
- **Username:** testuser
- **Password:** testpassword
- **Database:** testdb

#### PostgreSQL Example:
- **Host:** postgres (container name)
- **Port:** 5432
- **Username:** testuser
- **Password:** testpassword
- **Database:** testdb

### Connecting to External Databases

When connecting to databases outside the Docker network:

#### On All Platforms (Windows, macOS, Linux):
- **Host:** `host.docker.internal` - This is now configured to work on Linux too!
- **Port:** Your database port (e.g., 7200 for MariaDB, 3306 for MySQL, 5432 for PostgreSQL)

The docker-compose.yml includes `extra_hosts` configuration that makes `host.docker.internal` work on Linux:
```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

#### Alternative Methods:

1. **Use host networking mode** (see `docker-compose-host.yml`):
   - Access databases on host using `localhost` or `127.0.0.1`
   - Note: Port mapping doesn't work with host networking

2. **Use the host's actual IP address:**
   ```bash
   # Find your host IP
   ip addr show docker0 | grep inet
   # Or on Linux
   hostname -I
   ```
   - Then use that IP (e.g., `172.17.0.1` or `192.168.1.x`)

3. **Connect both containers to the same network:**
   - If your database is also in Docker, put them in the same network
   - Use the database container name as the hostname

#### Examples:

**MariaDB on host (port 7200):**
- Server: `host.docker.internal:7200`
- Username: your_username
- Password: your_password
- Database: your_database

**MySQL on host (default port):**
- Server: `host.docker.internal:3306` or just `host.docker.internal`
- Username: root
- Password: your_password

**Remote database:**
- Server: actual hostname or IP address
- Port: database port

## Development Mode

To enable development mode (live code reloading), uncomment the volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./adminer:/var/www/html/adminer
  - ./editor:/var/www/html/editor
  - ./plugins:/var/www/html/plugins
  - ./designs:/var/www/html/designs
```

Then rebuild:
```bash
docker-compose down
docker-compose up -d --build
```

## Docker Setup Script

Use the included script for easy management:

```bash
# Make script executable (Linux/Mac)
chmod +x docker-setup.sh

# Start Adminer
./docker-setup.sh start

# Stop Adminer
./docker-setup.sh stop

# Restart Adminer
./docker-setup.sh restart

# View logs
./docker-setup.sh logs

# Show status
./docker-setup.sh status

# Rebuild from scratch
./docker-setup.sh rebuild
```

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs adminer

# Rebuild and start
docker-compose up -d --build

# Remove all containers and volumes
docker-compose down -v

# Check container status
docker ps

# Enter container shell
docker exec -it adminer-app bash
```

## Troubleshooting

1. **Port already in use:**
   Change the host port in docker-compose.yml from 8060 to another port

2. **Database connection issues:**
   - Ensure database containers are running
   - Use container names as hostnames within the Docker network
   - Check firewall settings for external database connections

3. **Permission issues:**
   ```bash
   docker exec adminer-app chown -R www-data:www-data /var/www/html
   ```

4. **Build issues:**
   - Clear Docker cache: `docker system prune -a`
   - Rebuild without cache: `docker-compose build --no-cache`

5. **Can't access Adminer:**
   - Verify container is running: `docker ps`
   - Check logs: `docker logs adminer-app`
   - Test connectivity: `curl -I http://localhost:8060`

## Features Included

- ✅ PHP 8.2 with Apache
- ✅ All major database drivers (MySQL, PostgreSQL, SQLite, etc.)
- ✅ Adminer full version
- ✅ Adminer Editor
- ✅ All plugins included
- ✅ All design themes included
- ✅ Proper security headers
- ✅ Production-ready configuration