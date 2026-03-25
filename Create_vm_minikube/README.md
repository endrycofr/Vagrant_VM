# 🚀 Vagrant Minikube Lab

Setup local Kubernetes cluster menggunakan **Vagrant + VirtualBox + Docker + Minikube** dengan konfigurasi fleksibel berbasis `.env`.

---

## 🧱 Stack

- Vagrant (VM automation)
- VirtualBox (hypervisor)
- Docker (container runtime)
- Minikube (local Kubernetes)

---

## 📦 Requirements

Pastikan sudah terinstall:

- Vagrant
- VirtualBox
- Git
- (Opsional) SSH key

---

## 📁 Project Structure

```bash
.
├── Vagrantfile
├── .env
├── .env.example
└── ssh/
    └── key_ssh.pub
```
---

## 🔧 Environment Variables

| Variable      | Description                 | Default        |
| ------------- | --------------------------- | -------------- |
| BOX           | Base OS                     | ubuntu/jammy64 |
| HOSTNAME      | Hostname VM                 | minikube-vm    |
| VM_NAME       | Nama VM di VirtualBox       | minikube-vm    |
| MEMORY        | RAM (MB)                    | 4096           |
| CPU           | Jumlah CPU                  | 2              |
| NETWORK       | Network type (nat / bridge) | nat            |
| BRIDGE_IF     | Interface bridge            | Wi-Fi          |
| SSH_PUB       | Path ke public SSH key      | k3s.pem.pub    |
| AUTO_MINIKUBE | Auto start Minikube         | false          |

---

## 🔑 SSH Key Setup

### Opsi 1: Gunakan SSH key sendiri

Edit `.env`:

```bash
SSH_PUB=../ssh/key_ssh.pub
```

Pastikan file ada:

```bash
ls ../ssh/key_ssh.pub
```

---

### Opsi 2: Generate SSH key

```bash
ssh-keygen -t rsa -b 4096 -f ssh/key_ssh
```

---

### Opsi 3: Tanpa SSH key

- Bisa di-skip
- Vagrant tetap bisa SSH menggunakan default key

---

## 🌐 Network Mode

### NAT (Default)

- Internet tersedia
- Tidak bisa diakses dari LAN

---

### Bridge (WiFi / LAN)

```bash
NETWORK=bridge
BRIDGE_IF=Wi-Fi
```

Contoh:

- Windows:
  - Wi-Fi
  - Ethernet

- Linux:
  - wlp2s0
  - eth0

---

## 🚀 Usage

### 1. Jalankan VM

```bash
vagrant up
```

---

### 2. Masuk ke VM

```bash
vagrant ssh
```

---

### 3. Jalankan Minikube

```bash
minikube start --driver=docker
```

---

### 4. Cek cluster

```bash
kubectl get nodes
minikube status
```

---

## ⚡ Auto Start Minikube

Aktifkan di `.env`:

```bash
AUTO_MINIKUBE=true
```

---

## 📊 Arsitektur

```
Host Machine
  ↓
VirtualBox
  ↓
Vagrant VM (Ubuntu)
  ↓
Docker
  ↓
Minikube
  ↓
Kubernetes Cluster
```

---

## 🛠️ Troubleshooting

### ❌ SSH key tidak ditemukan

```bash
❌ SSH key not found
```

Solusi:

- Pastikan path benar
- Gunakan absolute path
- Atau disable SSH key di Vagrantfile

---

### ❌ Docker permission denied

```bash
newgrp docker
```

---

### ❌ Minikube gagal start

Cek docker:

```bash
docker ps
```

---

### ❌ VM lambat

Tambahkan resource:

```bash
MEMORY=8192
CPU=4
```

---

### ❌ Bridge tidak jalan

- Pastikan nama interface benar
- Cek dengan:
  - Windows: Network Adapter
  - Linux: `ip a`

---

## 🎯 Use Case

- Belajar Kubernetes
- Lab DevOps
- Testing deployment
- Simulasi CI/CD

---

## ⚠️ Notes

- Tidak untuk production
- Single node (Minikube)
- Gunakan multi-node untuk simulasi real

---

## 🚀 Next Improvement

- Multi-node cluster (master + worker)
- HA Kubernetes setup
- Integrasi Rancher
- Monitoring (Prometheus + Grafana)
