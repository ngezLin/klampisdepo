# Simple API Deployment Guide

### 1. In Local (Build & Upload)

Open your local terminal (Git Bash/PowerShell) and run:

```bash
cd c:/project/klampisDepo/api
GOOS=linux GOARCH=amd64 go build -o kd-api-new main.go
scp kd-api-new root@202.10.41.223:/var/www/kd-api/kd-api-new
```

_(Password: `Lin171816`)_

### 2. In VPS (Apply & Restart)

Connect to your VPS:

```bash
ssh root@202.10.41.223
```

Then run these commands to apply the new code and restart the API:

```bash
cd /var/www/kd-api/
pkill kd-api
mv kd-api-new kd-api
chmod +x kd-api
nohup ./kd-api > nohuput.log 2>&1 &
```

_(Optional) Check if it's running:_

```bash
tail -f nohuput.log
```
