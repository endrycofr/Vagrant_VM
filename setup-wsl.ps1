# =========================================
# Full Auto WSL + 3 Ubuntu + SSH (Fixed)
# =========================================

# === 0️⃣ Variabel ===
$basePath = "C:\Users\NUHA\Vagrant_VM"
$sshFolder = "$basePath\ssh"
$sshPub = "$sshFolder\k3s.pem.pub"
$sshPrivate = "$sshFolder\k3s"
$ubuntuTarGz = "$basePath\ubuntu-22.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"
$wslList = @("k3s-master1","k3s-master2","LB")

# === 1️⃣ Cek status WSL ===
Write-Host "`n[1] Cek status WSL..." -ForegroundColor Cyan
try {
    $wslCheck = wsl --status 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not active"
    }
} catch {
    Write-Host "WSL belum aktif. Mengaktifkan sekarang..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Host "`n⚠️ RESTART Windows terlebih dahulu, lalu jalankan script ini lagi!" -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

wsl --set-default-version 2

# === 2️⃣ Buat folder jika belum ada ===
Write-Host "`n[2] Membuat folder yang diperlukan..." -ForegroundColor Cyan
if (-not (Test-Path $basePath)) { 
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
    Write-Host "✅ Folder dibuat: $basePath" -ForegroundColor Green
}
if (-not (Test-Path $sshFolder)) { 
    New-Item -ItemType Directory -Path $sshFolder -Force | Out-Null
    Write-Host "✅ Folder dibuat: $sshFolder" -ForegroundColor Green
}

# === 3️⃣ Generate SSH key jika belum ada ===
if (-not (Test-Path $sshPub)) {
    Write-Host "`n[3] Membuat SSH key baru..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b 4096 -f $sshPrivate -N '""'
    Write-Host "✅ SSH key berhasil dibuat" -ForegroundColor Green
} else {
    Write-Host "`n[3] SSH key sudah ada, skip..." -ForegroundColor Yellow
}

# === 4️⃣ Download Ubuntu rootfs jika belum ada ===
if (-not (Test-Path $ubuntuTarGz)) {
    Write-Host "`n[4] Download Ubuntu 24.04 rootfs (~500MB)..." -ForegroundColor Cyan
    $url = "https://cloud-images.ubuntu.com/wsl/releases/24.04/20240423/ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz"
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $url -OutFile $ubuntuTarGz -ErrorAction Stop
        $ProgressPreference = 'Continue'
        Write-Host "✅ Download selesai!" -ForegroundColor Green
    } catch {
        Write-Host "Invoke-WebRequest gagal, mencoba curl..." -ForegroundColor Yellow
        curl.exe -L -o $ubuntuTarGz $url
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Download gagal!" -ForegroundColor Red
            Read-Host "Tekan Enter untuk keluar"
            exit
        }
    }
} else {
    Write-Host "`n[4] Ubuntu rootfs sudah ada, skip download..." -ForegroundColor Yellow
}

# === 5️⃣ Verifikasi file tar.gz ===
if (-not (Test-Path $ubuntuTarGz)) {
    Write-Host "❌ File Ubuntu rootfs tidak ditemukan! Hentikan script." -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}
Write-Host "`n[5] File rootfs siap: $ubuntuTarGz" -ForegroundColor Green

# === 6️⃣ Import & setup 3 WSL ===
foreach ($wsl in $wslList) {
    $folder = "$basePath\Ubuntu-$wsl"

    # Cek WSL sudah ada
    $existing = wsl -l -q 2>$null | Where-Object { $_.Trim() -eq $wsl }
    if ($existing) {
        Write-Host "`n⚠️ WSL '$wsl' sudah ada." -ForegroundColor Yellow
        $response = Read-Host "Hapus dan buat ulang? (y/n)"
        if ($response -eq 'y') {
            Write-Host "Menghapus WSL '$wsl'..." -ForegroundColor Yellow
            wsl --unregister $wsl
            if (Test-Path $folder) { 
                Remove-Item -Path $folder -Recurse -Force 
            }
            Start-Sleep -Seconds 2
        } else {
            Write-Host "Skip WSL '$wsl'" -ForegroundColor Yellow
            continue
        }
    }

    Write-Host "`n[6] Membuat WSL: $wsl di $folder..." -ForegroundColor Cyan
    if (-not (Test-Path $folder)) { 
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }

    wsl --import $wsl $folder $ubuntuTarGz --version 2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Gagal membuat WSL: $wsl" -ForegroundColor Red
        continue
    }

    Write-Host "✅ WSL '$wsl' berhasil dibuat" -ForegroundColor Green
    Start-Sleep -Seconds 3

    # Path SSH di WSL (D: -> /mnt/d/)
    $sshPathWSL = $sshPub.Replace("C:\", "/mnt/d/").Replace("\", "/")

    Write-Host "⚙️  Setting up $wsl..." -ForegroundColor Cyan

    # Setup hostname
    wsl -d $wsl -- bash -c "echo '$wsl' | sudo tee /etc/hostname > /dev/null"
    
    # Setup hosts
    wsl -d $wsl -- bash -c "sudo sed -i '/127.0.1.1/d' /etc/hosts"
    wsl -d $wsl -- bash -c "echo '127.0.1.1 $wsl' | sudo tee -a /etc/hosts > /dev/null"
    
    # Setup SSH directory
    wsl -d $wsl -- bash -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    
    # Copy SSH key
    wsl -d $wsl -- bash -c "if [ -f '$sshPathWSL' ]; then cat '$sshPathWSL' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo 'SSH key configured'; else echo 'SSH key not found at $sshPathWSL'; fi"
    
    # Install packages
    Write-Host "Installing packages di $wsl..." -ForegroundColor Cyan
    wsl -d $wsl -- bash -c "sudo apt update -qq && sudo apt install -y openssh-server vim git curl wget net-tools unzip"
    
    # Configure SSH
    wsl -d $wsl -- bash -c "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
    wsl -d $wsl -- bash -c "sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config"
    wsl -d $wsl -- bash -c "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    
    # Setup systemd
    wsl -d $wsl -- bash -c "echo '[boot]' | sudo tee /etc/wsl.conf > /dev/null"
    wsl -d $wsl -- bash -c "echo 'systemd=true' | sudo tee -a /etc/wsl.conf > /dev/null"
    
    # Start SSH
    wsl -d $wsl -- bash -c "sudo service ssh start"
    
    Write-Host "✅ Setup '$wsl' selesai" -ForegroundColor Green

    # Shutdown WSL untuk apply wsl.conf
    Write-Host "Restarting $wsl untuk apply systemd..." -ForegroundColor Yellow
    wsl --terminate $wsl
    Start-Sleep -Seconds 2
}

# === 7️⃣ Summary ===
Write-Host "`n════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ SELESAI! 3 WSL sudah siap." -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green

Write-Host "`n📋 Daftar WSL:" -ForegroundColor Cyan
wsl -l -v

Write-Host "`n📌 Cara pakai:" -ForegroundColor Cyan
Write-Host "`nMasuk ke WSL:" -ForegroundColor Yellow
foreach ($wslName in $wslList) {
    Write-Host "  wsl -d $wslName" -ForegroundColor White
}

Write-Host "`nStart semua WSL + SSH:" -ForegroundColor Yellow
foreach ($wslName in $wslList) {
    Write-Host "  wsl -d $wslName -- sudo service ssh start" -ForegroundColor White
}

Write-Host "`nCek IP WSL:" -ForegroundColor Yellow
Write-Host "  wsl -d k3s-master1 -- ip addr show eth0 | grep 'inet '" -ForegroundColor White

Write-Host "`nSSH antar WSL (dari dalam WSL):" -ForegroundColor Yellow
Write-Host "  ssh root@<ip-wsl-lain>" -ForegroundColor White

Write-Host "`nSSH key location:" -ForegroundColor Yellow
Write-Host "  Private: $sshPrivate" -ForegroundColor White
Write-Host "  Public:  $sshPub" -ForegroundColor White

Read-Host "`nTekan Enter untuk keluar"