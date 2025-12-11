# PowerShell script to attach USB device to WSL
# Run this as Administrator before programming the FPGA

Write-Host "=== Attaching DirtyJTAG Device to WSL ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

# List USB devices
Write-Host "Current USB devices:" -ForegroundColor Green
usbipd list

Write-Host ""
Write-Host "Attaching busid 2-5 (DirtyJTAG) to WSL..." -ForegroundColor Green

# Attach the device
try {
    usbipd attach --wsl --busid 2-5
    Write-Host ""
    Write-Host "SUCCESS! Device attached to WSL" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: make prog" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tip: Keep a WSL terminal open to maintain the connection" -ForegroundColor Yellow
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to attach device" -ForegroundColor Red
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. WSL is running (open a WSL terminal and keep it open)"
    Write-Host "  2. The device busid is correct (check with 'usbipd list')"
    Write-Host "  3. usbipd is installed (run: winget install usbipd)"
    Write-Host ""
    pause
    exit 1
}
