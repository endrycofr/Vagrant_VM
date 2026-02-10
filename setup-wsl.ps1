# # =========================================================
# # FULL AUTO: WSL + 3 Ubuntu + SSH + Port Forward + Firewall
# # =========================================================

# # =====================
# # CONFIG
# # =====================
# $basePath   = "C:\Users\NUHA\Vagrant_VM"
# $sshFolder  = "$basePath\ssh"
# $sshKey     = "$sshFolder\k3s.pem"
# $sshPub     = "$sshKey.pub"

# $rootfsUrl  = "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz"
# $rootfsFile = "$basePath\ubuntu-jammy.rootfs.tar.gz"

# $wslList = @(
#     @{ Name="k3s-master1"; Port=2222 },
#     @{ Name="k3s-master2"; Port=2223 },
#     @{ Name="LB";          Port=2224 }
# )

# # =====================
# # 1. CHECK WSL
# # =====================
# Write-Host "`n[1] Checking WSL..." -ForegroundColor Cyan
# try {
#     wsl --status | Out-Null
# } catch {
#     Write-Host "Installing WSL..." -ForegroundColor Yellow
#     wsl --install
#     Write-Host "RESTART WINDOWS lalu jalankan ulang script" -ForegroundColor Red
#     exit
# }
# wsl --set-default-version 2

# # =====================
# # 2. FOLDER SETUP
# # =====================
# Write-Host "`n[2] Folder setup..." -ForegroundColor Cyan
# New-Item -ItemType Directory -Force -Path $basePath, $sshFolder | Out-Null

# # =====================
# # 3. SSH KEY
# # =====================
# if (-not (Test-Path $sshKey)) {
#     Write-Host "`n[3] Generating SSH key (.pem)..." -ForegroundColor Cyan
#     ssh-keygen -t rsa -b 4096 -f $sshKey -N ""
# }

# # =====================
# # 4. DOWNLOAD ROOTFS
# # =====================
# if (-not (Test-Path $rootfsFile)) {
#     Write-Host "`n[4] Download Ubuntu rootfs (~500MB)..." -ForegroundColor Cyan
#     curl.exe -L -o $rootfsFile $rootfsUrl
# }

# # =====================
# # 5. CREATE WSL
# # =====================
# foreach ($item in $wslList) {

#     $name = $item.Name
#     $port = $item.Port
#     $folder = "$basePath\Ubuntu-$name"

#     Write-Host "`n[5] Setup WSL: $name" -ForegroundColor Cyan

#     if (wsl -l -q | Select-String "^$name$") {
#         wsl --unregister $name
#         Remove-Item -Recurse -Force $folder -ErrorAction SilentlyContinue
#     }

#     New-Item -ItemType Directory -Force -Path $folder | Out-Null

#     wsl --import $name $folder $rootfsFile --version 2
#     Start-Sleep 3

#     $sshPathWSL = $sshPub.Replace("C:\","/mnt/c/").Replace("\","/")

#     wsl -d $name -- bash -c "
#         apt update -qq
#         apt install -y openssh-server sudo net-tools
#         echo '$name' > /etc/hostname
#         mkdir -p ~/.ssh
#         chmod 700 ~/.ssh
#         cat '$sshPathWSL' >> ~/.ssh/authorized_keys
#         chmod 600 ~/.ssh/authorized_keys
#         sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#         sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
#         service ssh start
#     "

#     wsl --terminate $name
# }

# # =====================
# # 6. PORT FORWARD
# # =====================
# Write-Host "`n[6] Setup Port Forwarding..." -ForegroundColor Cyan
# netsh interface portproxy reset | Out-Null

# foreach ($item in $wslList) {
#     $name = $item.Name
#     $port = $item.Port
#     $ip = (wsl -d $name -- hostname -I).Trim().Split(" ")[0]

#     netsh interface portproxy add v4tov4 `
#         listenaddress=0.0.0.0 `
#         listenport=$port `
#         connectaddress=$ip `
#         connectport=22
# }

# # =====================
# # 7. FIREWALL
# # =====================
# Write-Host "`n[7] Open Firewall..." -ForegroundColor Cyan
# foreach ($item in $wslList) {
#     $rule = "WSL-SSH-$($item.Port)"
#     if (-not (Get-NetFirewallRule -DisplayName $rule -ErrorAction SilentlyContinue)) {
#         New-NetFirewallRule `
#             -DisplayName $rule `
#             -Direction Inbound `
#             -Protocol TCP `
#             -LocalPort $item.Port `
#             -Action Allow `
#             -Profile Any
#     }
# }

# # =====================
# # DONE
# # =====================
# Write-Host "`n===============================" -ForegroundColor Green
# Write-Host "✅ SETUP SELESAI" -ForegroundColor Green
# Write-Host "===============================" -ForegroundColor Green

# Write-Host "`nSSH Access:" -ForegroundColor Cyan
# Write-Host "ssh -i $sshKey root@localhost -p 2222"
# Write-Host "ssh -i $sshKey root@localhost -p 2223"
# Write-Host "ssh -i $sshKey root@localhost -p 2224"

# Write-Host "`nWSL List:"
# wsl -l -v




# =========================================
# FULL AUTO INSTALL:
# WSL2 + 3 Ubuntu (k3s-master1, k3s-master2, lb)
# SSH key (.pem) aman + SSH aktif
# =========================================

# ---------- KONFIGURASI ----------
$BasePath = "D:\ISO OS linux\Virtualbox\vagrant"
$WSLPath  = "$BasePath\wsl"
$SSHPath  = "$BasePath\ssh"
$KeyName  = "k3s"

$Distros  = @("k3s-master1","k3s-master2","lb")

$UbuntuURL = "https://cloud-images.ubuntu.com/wsl/jammy/current/ubuntu-jammy-wsl-amd64.rootfs.tar.gz"
$RootfsGz  = "$BasePath\ubuntu-jammy.rootfs.tar.gz"
$RootfsTar = "$BasePath\ubuntu-jammy.rootfs.tar"

# ---------- 1. AKTIFKAN WSL ----------
Write-Host "`n[1] Mengaktifkan WSL & VirtualMachinePlatform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
wsl --set-default-version 2

# ---------- 2. BUAT FOLDER ----------
Write-Host "[2] Menyiapkan folder..."
New-Item -ItemType Directory -Force -Path $BasePath,$WSLPath,$SSHPath | Out-Null

# ---------- 3. SSH KEY (.pem) ----------
$PrivateKey = "$SSHPath\$KeyName.pem"
$PublicKey  = "$SSHPath\$KeyName.pub"

if (-not (Test-Path $PrivateKey)) {
    Write-Host "[3] Generate SSH key (.pem)..."
    ssh-keygen -t rsa -b 4096 -m PEM -f $PrivateKey -N ""
}

# ---------- 4. DOWNLOAD ROOTFS ----------
if (-not (Test-Path $RootfsGz)) {
    Write-Host "[4] Download Ubuntu rootfs..."
    Invoke-WebRequest -Uri $UbuntuURL -OutFile $RootfsGz
}

# ---------- 5. EXTRACT TAR ----------
if (-not (Test-Path $RootfsTar)) {
    Write-Host "[5] Extract rootfs..."
    tar -xzf $RootfsGz -C $BasePath
    Rename-Item "$BasePath\rootfs.tar" $RootfsTar -Force
}

# ---------- 6. HAPUS WSL LAMA (AMAN) ----------
Write-Host "[6] Bersihkan WSL lama (jika ada)..."
foreach ($d in $Distros) {
    wsl --unregister $d 2>$null
}

# ---------- 7. IMPORT & SETUP ----------
foreach ($d in $Distros) {

    $DistroPath = "$WSLPath\$d"
    Write-Host "`n[7] Import WSL: $d"

    wsl --import $d $DistroPath $RootfsTar --version 2

    # setup SSH + hostname
    wsl -d $d -- bash -c "
        set -e
        echo '$d' > /etc/hostname
        apt update
        apt install -y openssh-server sudo net-tools iproute2
        mkdir -p /root/.ssh
        cat /mnt/d/ISO\ OS\ linux/Virtualbox/vagrant/ssh/$KeyName.pub >> /root/.ssh/authorized_keys
        chmod 700 /root/.ssh
        chmod 600 /root/.ssh/authorized_keys
        sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        service ssh restart
    "
}

# ---------- 8. INFO ----------
Write-Host "`n================================="
Write-Host "SELESAI ✅"
Write-Host "Cek distro : wsl -l -v"
Write-Host "SSH key    : $PrivateKey"
Write-Host "Login SSH  : ssh -i $PrivateKey root@<IP-WSL>"
Write-Host "================================="
