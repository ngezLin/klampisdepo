# Android SDK Command-line Tools Installer
# Pure ASCII Version (Avoids PowerShell encoding corruption)

$sdkDir = "C:\Users\vince\AppData\Local\Android\Sdk"
$toolsDir = "$sdkDir\cmdline-tools"
$tempZip = "$env:TEMP\cmdline-tools.zip"

Write-Host "=== Android SDK Command-line Tools Installer ==="

# 1. Download official Google Android SDK Tools
Write-Host "1. Downloading Android SDK Command-line tools from Google..."
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -ErrorAction Stop
    Write-Host "-> Download complete."
} catch {
    Write-Host "ERROR: Failed to download: $_"
    exit
}

# 2. Extract tools
Write-Host "2. Creating target directories..."
if (Test-Path "$toolsDir\temp") { Remove-Item -Recurse -Force "$toolsDir\temp" }
$null = New-Item -ItemType Directory -Force -Path "$toolsDir\temp"

Write-Host "3. Extracting files..."
try {
    Expand-Archive -Path $tempZip -DestinationPath "$toolsDir\temp" -Force
    Write-Host "-> Extraction complete."
} catch {
    Write-Host "ERROR: Failed to extract zip: $_"
    Remove-Item -Force $tempZip
    exit
}

# 3. Restructure to: cmdline-tools/latest/bin/sdkmanager
Write-Host "4. Restructuring files to 'cmdline-tools/latest'..."
if (Test-Path "$toolsDir\latest") { Remove-Item -Recurse -Force "$toolsDir\latest" }
$null = New-Item -ItemType Directory -Force -Path "$toolsDir\latest"

Move-Item -Path "$toolsDir\temp\cmdline-tools\*" -Destination "$toolsDir\latest" -Force

# 4. Clean up temp files
Write-Host "5. Cleaning up temporary files..."
Remove-Item -Recurse -Force "$toolsDir\temp"
Remove-Item -Force $tempZip

Write-Host ""
Write-Host "=== Installation Successful! ==="
Write-Host "Android Command-line Tools installed under: $toolsDir\latest"
Write-Host "Please run the following command next:"
Write-Host "  flutter doctor --android-licenses"
