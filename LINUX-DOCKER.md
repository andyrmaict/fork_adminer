# Linux Docker Connectivity Guide

This guide helps you connect Adminer running in Docker to databases on your Linux host machine.

## The Problem

On Windows and macOS, Docker Desktop automatically provides `host.docker.internal` to access services on the host machine. On Linux, this requires additional configuration.

## Solution 1: Using extra_hosts (RECOMMENDED) ✅

The default `docker-compose.yml` now includes this configuration:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

This makes `host.docker.internal` work on Linux exactly like Windows/macOS!

### Usage:

1. **Start Adminer:**
   ```bash
   docker-compose up -d
   ```

2. **Connect to your database:**
   - Server: `host.docker.internal:7200` (for MariaDB on port 7200)
   - Server: `host.docker.internal:3306` (for MySQL on default port)
   - Username: your_username
   - Password: your_password
   - Database: your_database

3. **That's it!** It now works cross-platform.

## Solution 2: Using Host IP Address

If Solution 1 doesn't work, you can use the Docker bridge IP or your host's actual IP.

### Find your Docker bridge IP:

```bash
ip addr show docker0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

Usually it's `172.17.0.1`

### Find your host's network IP:

```bash
hostname -I | awk '{print $1}'
```

### Connect using the IP:
- Server: `172.17.0.1:7200` (or your actual IP)

## Solution 3: Host Network Mode

Use `docker-compose-host.yml` which uses host networking:

```bash
docker-compose -f docker-compose-host.yml up -d
```

**Note:** With host networking:
- Adminer will be on port 80 (not 8060)
- Access: `http://localhost/adminer/`
- Connect to databases using `localhost:7200` or `127.0.0.1:7200`

## Solution 4: Shared Docker Network

If your database is also in Docker, put both containers in the same network:

```yaml
services:
  adminer:
    networks:
      - shared-network
  
  mariadb:
    networks:
      - shared-network

networks:
  shared-network:
    name: my-shared-network
```

Then connect using the container name as hostname: `mariadb:3306`

## Verification Steps

### 1. Check if Adminer can see the host:

```bash
# Enter the Adminer container
docker exec -it adminer-app bash

# Try to ping host.docker.internal
ping -c 2 host.docker.internal

# Try to connect to your database port
nc -zv host.docker.internal 7200

# Exit the container
exit
```

### 2. Check if your database is listening:

```bash
# On your host machine
sudo netstat -tlnp | grep 7200
# or
sudo ss -tlnp | grep 7200
```

### 3. Check firewall rules:

```bash
# Check if firewall is blocking Docker
sudo iptables -L -n | grep 7200

# For UFW users
sudo ufw status
```

## Common Issues and Fixes

### Issue 1: Connection Refused

**Cause:** Database not listening on all interfaces or only on localhost.

**Fix:** Configure your database to listen on `0.0.0.0` or your host's IP.

For MariaDB/MySQL, edit `/etc/mysql/my.cnf`:
```ini
[mysqld]
bind-address = 0.0.0.0
```

Then restart:
```bash
sudo systemctl restart mariadb
```

### Issue 2: Firewall Blocking

**Cause:** Linux firewall blocking Docker bridge connections.

**Fix:** Allow Docker subnet access:
```bash
# For iptables
sudo iptables -A INPUT -s 172.17.0.0/16 -p tcp --dport 7200 -j ACCEPT

# For UFW
sudo ufw allow from 172.17.0.0/16 to any port 7200
```

### Issue 3: SELinux Blocking (Red Hat/CentOS/Fedora)

**Cause:** SELinux preventing container network access.

**Fix:**
```bash
# Temporarily disable to test
sudo setenforce 0

# If it works, add permanent rule
sudo setsebool -P container_connect_any 1

# Re-enable SELinux
sudo setenforce 1
```

### Issue 4: host.docker.internal Not Resolving

**Cause:** Older Docker version or misconfiguration.

**Fix:** Update Docker to latest version:
```bash
# Check version
docker --version

# Update Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Or manually add to `/etc/hosts` in container:
```bash
docker exec -it adminer-app sh -c "echo '172.17.0.1 host.docker.internal' >> /etc/hosts"
```

## Quick Reference

| Method | Connection String | When to Use |
|--------|------------------|-------------|
| extra_hosts (default) | `host.docker.internal:7200` | Best for cross-platform |
| Docker bridge IP | `172.17.0.1:7200` | Fallback if extra_hosts fails |
| Host IP | `192.168.1.x:7200` | Specific network interface |
| Host networking | `localhost:7200` | Full host network access |
| Container name | `mariadb:3306` | Database also in Docker |

## Testing Your Setup

After making changes:

```bash
# Stop and remove old containers
docker-compose down

# Start with new configuration
docker-compose up -d

# Check logs
docker-compose logs adminer

# Verify extra_hosts is configured
docker inspect adminer-app | grep -A5 ExtraHosts
```

## Need More Help?

1. Check Docker logs: `docker logs adminer-app`
2. Check database logs: `sudo journalctl -u mariadb -f`
3. Test from host: `mysql -h 127.0.0.1 -P 7200 -u root -p`
4. Test from container: `docker exec -it adminer-app nc -zv host.docker.internal 7200`
