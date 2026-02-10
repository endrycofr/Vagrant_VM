# === 1️⃣ Install WSL jika belum ada ===
Write-Host "Cek dan install WSL..."
wsl --install -d Ubuntu-22.04

# Pastikan WSL versi 2
wsl --set-default-version 2

# Tunggu user tekan enter sebelum lanjut
Read-Host "WSL sudah terinstall? Tekan Enter untuk lanjut..."

# === 2️⃣ Setup folder untuk WSL custom ===
$basePath = "D:\ISO OS linux\wsl"  # Ganti sesuai folder kamu
$sshPub = "$basePath\ssh\k3s.pub"   # Public key SSH kamu
$ubuntuImage = "$basePath\ubuntu-22.04.tar"

# Download Ubuntu rootfs jika belum ada
if (-not (Test-Path $ubuntuImage)) {
    Write-Host "Download Ubuntu 22.04 rootfs..."
    Invoke-WebRequest -Uri "https://partner-images.canonical.com/core/jammy/current/ubuntu-22.04-server-cloudimg-amd64-wsl.rootfs.tar.gz" -OutFile "$ubuntuImage.gz"

    Write-Host "Extract Ubuntu rootfs..."
    # Gunakan 7zip atau tool gzip, di PowerShell bisa pakai:
    # Pastikan gzip ada, atau unzip manual
    gzip -d "$ubuntuImage.gz"
}

# === 3️⃣ Buat list WSL ===
$wslList = @("k3s-master1","k3s-master2","LB")

foreach ($wsl in $wslList) {
    $folder = "$basePath\Ubuntu-$wsl"
    Write-Host "Membuat WSL $wsl di $folder..."
    
    # Import WSL baru
    wsl --import $wsl $folder $ubuntuImage --version 2

    # Set hostname, SSH key, install OpenSSH
    # Gunakan path WSL sesuai drive (D: → /mnt/d/)
    $sshPathWSL = "/mnt/d/ISO\ OS\ linux/wsl/ssh/k3s.pub"

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

Write-Host "✅ Selesai membuat 3 WSL dengan hostname dan SSH key!"
Write-Host "Cek WSL dengan: wsl -l -v"
    