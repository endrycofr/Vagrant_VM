# =========================================================
# FULL AUTO: WSL + 3 Ubuntu + SSH + Port Forward + Firewall
# =========================================================

# =====================
# CONFIG
# =====================
$basePath   = "C:\Users\NUHA\Vagrant_VM"
$sshFolder  = "$basePath\ssh"
$sshKey     = "$sshFolder\k3s.pem"
$sshPub     = "$sshKey.pub"

$rootfsUrl  = "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
$rootfsFile = "$basePath\ubuntu-jammy.rootfs.tar.gz"

$wslList = @(
    @{ Name="k3s-master1"; Port=2222 },
    @{ Name="k3s-master2"; Port=2223 },
    @{ Name="LB";          Port=2224 }
)

# =====================
# 1. CHECK WSL
# =====================
Write-Host "`n[1] Checking WSL..." -ForegroundColor Cyan
try {
    wsl --status | Out-Null
} catch {
    Write-Host "Installing WSL..." -ForegroundColor Yellow
    wsl --install
    Write-Host "RESTART WINDOWS lalu jalankan ulang script" -ForegroundColor Red
    exit
}
wsl --set-default-version 2

# =====================
# 2. FOLDER SETUP
# =====================
Write-Host "`n[2] Folder setup..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $basePath, $sshFolder | Out-Null

# =====================
# 3. SSH KEY
# =====================
if (-not (Test-Path $sshKey)) {
    Write-Host "`n[3] Generating SSH key (.pem)..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b 4096 -f $sshKey -N ""
}

# =====================
# 4. DOWNLOAD ROOTFS
# =====================
if (-not (Test-Path $rootfsFile)) {
    Write-Host "`n[4] Download Ubuntu rootfs (~500MB)..." -ForegroundColor Cyan
    curl.exe -L -o $rootfsFile $rootfsUrl
}

# =====================
# 5. CREATE WSL
# =====================
foreach ($item in $wslList) {

    $name = $item.Name
    $port = $item.Port
    $folder = "$basePath\Ubuntu-$name"

    Write-Host "`n[5] Setup WSL: $name" -ForegroundColor Cyan

    if (wsl -l -q | Select-String "^$name$") {
        wsl --unregister $name
        Remove-Item -Recurse -Force $folder -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Force -Path $folder | Out-Null

    wsl --import $name $folder $rootfsFile --version 2
    Start-Sleep 3

    $sshPathWSL = $sshPub.Replace("C:\","/mnt/c/").Replace("\","/")

    wsl -d $name -- bash -c "
        apt update -qq
        apt install -y openssh-server sudo net-tools
        echo '$name' > /etc/hostname
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        cat '$sshPathWSL' >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
        sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        service ssh start
    "

    wsl --terminate $name
}

# =====================
# 6. PORT FORWARD
# =====================
Write-Host "`n[6] Setup Port Forwarding..." -ForegroundColor Cyan
netsh interface portproxy reset | Out-Null

foreach ($item in $wslList) {
    $name = $item.Name
    $port = $item.Port
    $ip = (wsl -d $name -- hostname -I).Trim().Split(" ")[0]

    netsh interface portproxy add v4tov4 `
        listenaddress=0.0.0.0 `
        listenport=$port `
        connectaddress=$ip `
        connectport=22
}

# =====================
# 7. FIREWALL
# =====================
Write-Host "`n[7] Open Firewall..." -ForegroundColor Cyan
foreach ($item in $wslList) {
    $rule = "WSL-SSH-$($item.Port)"
    if (-not (Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule `
            -DisplayName $rule `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $item.Port `
            -Action Allow `
            -Profile Any
    }
}

# =====================
# DONE
# =====================
Write-Host "`n===============================" -ForegroundColor Green
Write-Host "✅ SETUP SELESAI" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

Write-Host "`nSSH Access:" -ForegroundColor Cyan
Write-Host "ssh -i $sshKey root@localhost -p 2222"
Write-Host "ssh -i $sshKey root@localhost -p 2223"
Write-Host "ssh -i $sshKey root@localhost -p 2224"

Write-Host "`nWSL List:"
wsl -l -v
