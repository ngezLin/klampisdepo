# VPS Deployment Guide for KlampisDepo API

This guide provides step-by-step instructions on how to build the Go API locally on your Windows machine, upload it to your Ubuntu VPS (`202.10.41.223`), and restart the service so the changes take effect.

---

## 1. Build the Go Binary for Linux

Since your server runs Linux, you must cross-compile the Go API on your Windows machine so that it can run natively on the VPS.

1. Open your terminal (Git Bash, PowerShell, or Command Prompt).
2. Navigate to your api directory:
   ```bash
   cd c:/project/klampisDepo/api
   ```
3. Run the Go build command specifying the target OS and Architecture:
   ```bash
   GOOS=linux GOARCH=amd64 go build -o kd-api-new main.go
   ```
   > **Note:** We name the output file `kd-api-new` so that we can upload it safely without conflicting with the `kd-api` process that is currently running and locking the file on the server.

---

## 2. Upload the Binary to the VPS

Next, you will securely copy (`scp`) the built binary to the deployment folder on your server (`/var/www/kd-api/`).

1. While still in the `api` directory, run the `scp` command:
   ```bash
   scp kd-api-new root@202.10.41.223:/var/www/kd-api/kd-api-new
   ```
2. When prompted, enter your server password (`Lin171816`).
3. Wait for the upload to reach 100%.

---

## 3. SSH into the VPS and Restart the API

Now you need to log into the server, replace the old background program with the newly uploaded one, and start it.

1. Connect to your server using SSH:
   ```bash
   ssh root@202.10.41.223
   ```
2. Enter your password (`Lin171816`).
3. Once logged in, navigate to the API directory:
   ```bash
   cd /var/www/kd-api/
   ```
4. Stop the currently running API process:
   ```bash
   pkill kd-api
   ```
5. Overwrite the old binary with the new one we just uploaded:
   ```bash
   mv kd-api-new kd-api
   ```
   > **Note:** This `mv` command essentially renames `kd-api-new` to `kd-api`, replacing the old executable. When the API starts again, it will boot using the newly uploaded code but under its expected name `kd-api`.
6. Make sure the new binary has execute permissions:
   ```bash
   chmod +x kd-api
   ```
7. Start the API in the background using `nohup` (this ensures it keeps running even after you exit SSH):
   ```bash
   nohup ./kd-api > nohuput.log 2>&1 &
   ```

_(Optional)_ To confirm the API is running correctly, you can view the live logs using:

```bash
tail -f nohuput.log
```

Press `Ctrl+C` to exit the log view.

---

**That's it! Your new API code is now live on the VPS.**
