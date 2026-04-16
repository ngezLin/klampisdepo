# API Deployment Guide

## Server Details

- **Host**: 202.10.41.223
- **Port**: 3306 (MySQL)
- **Database**: kd_db
- **DB Username**: user1
- **DB Password**: Kd171816!X
- **SSH User**: root
- **SSH Key**: `C:\Users\vince\OneDrive\Documents\ssh\id_ed25519`
- **API Path**: `/var/www/kd-api`
- **Root Password**: JJyAfg5!XJFn

---

## Step 1: Build Linux Binary (Local)

### PowerShell

```powershell
cd 'd:\project\klampisdepo\api'
$env:GOOS = 'linux'
$env:GOARCH = 'amd64'
go build -o main
```

### Git Bash

```bash
cd /d/project/klampisdepo/api
GOOS=linux GOARCH=amd64 go build -o main
```

---

## Step 2: Upload to VPS

### PowerShell

```powershell
cd 'd:\project\klampisdepo\api'
scp -i 'C:\Users\vince\OneDrive\Documents\ssh\id_ed25519' main root@202.10.41.223:/var/www/kd-api
```

### Git Bash

```bash
cd /d/project/klampisdepo/api
scp -i ~/.ssh/id_ed25519 main root@202.10.41.223:/var/www/kd-api
```

---

## Step 3: Deploy on VPS

### Connect to VPS

```bash
ssh -i 'C:\Users\vince\OneDrive\Documents\ssh\id_ed25519' root@202.10.41.223
```

### Or with password (if key doesn't work)

```bash
ssh root@202.10.41.223
# Password: JJyAfg5!XJFn
```

---

## Step 4: Run on VPS

Once connected via SSH:

```bash
cd /var/www

# Stop old process (if running)
pkill -f kd-api || true

# Wait a moment
sleep 2

# Start API in background
nohup ./kd-api > nohuput.log 2>&1 &

# Verify it's running
ps aux | grep kd-api | grep -v grep
```

---

## Monitoring

### View live logs

```bash
tail -f /var/www/nohuput.log
```

### Check if service is running

```bash
ps aux | grep kd-api
```

### View last 50 lines of log

```bash
tail -50 /var/www/nohuput.log
```

---

## Services Management

### Restart Services

```bash
systemctl start nginx
systemctl start mysql
systemctl restart nginx
systemctl restart mysql
```

### Check Service Status

```bash
systemctl status nginx
systemctl status mysql
```

### Enable UFW (Firewall)

```bash
sudo ufw enable
sudo ufw status
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3306
```

---

## Troubleshooting

### If binary won't start

```bash
# Check if there's a permission error
./kd-api
```

### If port is already in use

```bash
# Find process using port 8080
lsof -i :8080
# Kill the process
kill -9 <PID>
```

### View systemd logs (if running as service)

```bash
journalctl -u kd-api -f
```

---

## Quick Deployment Script

Save as `deploy.sh`:

```bash
#!/bin/bash
set -e

echo "📦 Building binary..."
GOOS=linux GOARCH=amd64 go build -o main

echo "📤 Uploading to VPS..."
scp -i ~/.ssh/id_ed25519 main root@202.10.41.223:/var/www/kd-api

echo "🚀 Starting API on VPS..."
ssh -i ~/.ssh/id_ed25519 root@202.10.41.223 << 'EOF'
cd /var/www
pkill -f kd-api || true
sleep 1
nohup ./kd-api > nohuput.log 2>&1 &
sleep 2
ps aux | grep kd-api | grep -v grep
EOF

echo "✅ Deployment complete!"
```

Make it executable:

```bash
chmod +x deploy.sh
./deploy.sh
```
