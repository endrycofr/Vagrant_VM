# === 1️⃣ Install WSL jika belum ada ===
Write-Host "Cek dan install WSL..."
wsl --install -d Ubuntu-22.04

# Pastikan WSL versi 2
wsl --set-default-version 2

# Tunggu user tekan enter sebelum lanjut
Read-Host "WSL sudah terinstall? Tekan Enter untuk lanjut..."

# =========================================
# Full Auto WSL + 3 Ubuntu + SSH
# =========================================

# === 0️⃣ Variabel ===
$basePath = "C:\users\NUHA\Vagrant_VM"   # Folder tempat WSL & SSH
$sshFolder = "$basePath\ssh"
$sshPub = "$sshFolder\k3s.pub"
$sshPrivate = "$sshFolder\k3s"
$ubuntuTarGz = "$basePath\ubuntu-22.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"
$ubuntuTar = "$basePath\ubuntu-22.04.tar"
$wslList = @("k3s-master1","k3s-master2","LB")

# === 1️⃣ Aktifkan WSL & VM Platform ===
Write-Host "`n[1] Mengaktifkan WSL & Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2

Write-Host "Restart Windows dulu jika baru aktifkan WSL. Tekan Enter untuk lanjut..."
Read-Host

# === 2️⃣ Buat folder jika belum ada ===
if (-not (Test-Path $basePath)) { New-Item -ItemType Directory -Path $basePath }
if (-not (Test-Path $sshFolder)) { New-Item -ItemType Directory -Path $sshFolder }

# === 3️⃣ Generate SSH key jika belum ada ===
if (-not (Test-Path $sshPub)) {
    Write-Host "`n[2] Membuat SSH key baru..."
    ssh-keygen -t rsa -b 4096 -f $sshPrivate -N ""
    Copy-Item "$sshPrivate.pub" $sshPub -Force
}

# === 4️⃣ Download Ubuntu rootfs jika belum ada ===
if (-not (Test-Path $ubuntuTarGz)) {
    Write-Host "`n[3] Download Ubuntu 22.04 rootfs..."
    $url = "https://partner-images.canonical.com/core/jammy/current/ubuntu-22.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"
    $output = $ubuntuTarGz
    # Pakai BITSAdmin (bawaan Windows)
    bitsadmin /transfer myDownloadJob /download /priority normal $url $output
}

# === 5️⃣ Extract .tar.gz ke .tar ===
if (-not (Test-Path $ubuntuTar)) {
    Write-Host "`n[4] Extract Ubuntu rootfs..."
    # Windows 10/11 sudah ada tar.exe
    tar -xvzf $ubuntuTarGz -C $basePath
    # rename folder 'rootfs' jadi ubuntu-22.04.tar jika perlu
    Rename-Item "$basePath\rootfs" $ubuntuTar -Force
}

# === 6️⃣ Import & setup 3 WSL ===
foreach ($wsl in $wslList) {
    $folder = "$basePath\Ubuntu-$wsl"
    Write-Host "`n[5] Membuat WSL: $wsl di $folder..."
    
    # Import WSL
    wsl --import $wsl $folder $ubuntuTar --version 2

    # Path SSH di WSL (C: -> /mnt/c/)
    $sshPathWSL = "/mnt/c/users/NUHA/Vagrant_VM/ssh/k3s.pub"

    # Setup hostname, hosts, SSH key, install tools
    wsl -d $wsl -- bash -c "
        echo $wsl | sudo tee /etc/hostname
        sudo sed -i '1i127.0.0.1 $wsl' /etc/hosts
        mkdir -p ~/.ssh
        cat $sshPathWSL >> ~/.ssh/authorized_keys
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/authorized_keys
        sudo apt update && sudo apt install -y openssh-server vim git curl wget net-tools unzip
        sudo service ssh start
    "
}

Write-Host "`n✅ Selesai! 3 WSL sudah siap dengan hostname dan SSH key."
Write-Host "Cek WSL: wsl -l -v"
Write-Host "SSH antar WSL sudah bisa tanpa password."