# Deployment Skills & VPS Runbook

This guide outlines the server environments, build commands, and execution runbooks for deploying the **Klampis Depo** API backend service onto the production VPS.

---

## 1. Environment Details

*   **Production VPS IP Address**: `202.10.41.223` (Running Linux AMD64)
*   **Production API Domain**: `https://api.klampisdepo.com`
*   **SSH Private Key Path**: `C:\Users\vince\OneDrive\Documents\ssh\id_ed25519`
*   **Nginx configuration**: Proxies public incoming HTTP(S) traffic to internal port `8080`, where the Go API daemon (`kd-api`) listens.

---

## 2. Build & Deploy Runbook Commands

Execute these steps in sequence from Windows PowerShell starting from the backend `api` directory:

### Step 1: Cross-Compile the Go Binary for Linux AMD64
To compile a binary compatible with the target Linux production host, run:
```powershell
$env:GOOS="linux"; $env:GOARCH="amd64"; go build -o main .
```

### Step 2: Upload the Compiled Binary to the VPS Temp Folder
Securely copy the binary to `/tmp/kd-api` on the remote server:
```powershell
scp -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no main root@202.10.41.223:/tmp/kd-api
```

### Step 3: Run Deployment Commands & Restart Service via SSH
SSH into the server to backup the running binary, move the new binary to the production path, assign execution permissions, and restart the `kd-api` systemd service:
```powershell
ssh -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no root@202.10.41.223 "mv /var/www/kd-api /var/www/kd-api.backup.previous; mv /tmp/kd-api /var/www/kd-api; chmod +x /var/www/kd-api; systemctl restart kd-api"
```

### Step 4: Monitor Output Service Logs
Check the latest output logs to verify that the daemon booted successfully on port `8080` without panicking:
```powershell
ssh -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no root@202.10.41.223 "journalctl -u kd-api -n 40 --no-pager"
```
