## Instalasi Vagrant & VirtualBox

Environment lab ini menggunakan **Vagrant** sebagai provisioning tool dan **VirtualBox** sebagai hypervisor.  
Pastikan keduanya terinstall dan saling terhubung dengan benar sebelum menjalankan project.

---

### 1️⃣ Instalasi VirtualBox

VirtualBox berfungsi sebagai hypervisor untuk menjalankan VM.

#### Windows / macOS / Linux

Unduh dan install VirtualBox dari situs resmi:

https://www.virtualbox.org/wiki/Downloads

Pastikan:

- VirtualBox berhasil terinstall
- Versi VirtualBox **kompatibel dengan Vagrant**
- Extension Pack (opsional tapi direkomendasikan) terinstall

Verifikasi instalasi:

```bash
VBoxManage --version
```

Jika versi muncul, VirtualBox siap digunakan.

---

### 2️⃣ Instalasi Vagrant

Vagrant digunakan untuk:

- membuat VM secara otomatis
- mengatur network
- menjalankan provisioning awal

Unduh Vagrant dari situs resmi:

[https://developer.hashicorp.com/vagrant/downloads](https://developer.hashicorp.com/vagrant/downloads)

Install sesuai OS kamu (Windows / macOS / Linux).

Verifikasi instalasi:

```bash
vagrant --version
```

---

### 3️⃣ Integrasi Vagrant dengan VirtualBox

Vagrant **otomatis menggunakan VirtualBox** sebagai provider default jika tersedia.

Cek provider yang tersedia:

```bash
vagrant plugin list
```

Pastikan VirtualBox terdeteksi:

```bash
vagrant up --provider=virtualbox
```

Jika tidak ada error, berarti:

- Vagrant ✔
- VirtualBox ✔
- Integrasi keduanya ✔

---

### 4️⃣ Download Box Ubuntu (Otomatis)

Project ini menggunakan box:

```
ubuntu/jammy64
```

Saat pertama kali menjalankan:

```bash
vagrant up
```

Vagrant akan otomatis:

- mendownload box Ubuntu
- menyimpannya di local cache
- menggunakannya untuk semua VM

Tidak perlu download manual.

---

### 5️⃣ Verifikasi Provider VirtualBox

Cek status VM:

```bash
vagrant status
```

Atau lewat GUI VirtualBox, kamu akan melihat VM berikut:

- k3s-master1
- k3s-master2
- k3s-master3
- lb

---

### 6️⃣ Catatan Khusus Windows

Jika menggunakan Windows:

- Jalankan terminal sebagai **Administrator**
- Pastikan **Hyper-V dimatikan**
- Virtualization (VT-x / AMD-V) aktif di BIOS

Jika Hyper-V aktif, VirtualBox **tidak akan bisa jalan**.

---

## Alur Singkat Setup

1. Install VirtualBox
2. Install Vagrant
3. Clone repository
4. Jalankan `vagrant up`
5. VM siap digunakan untuk K3s + Ansible

---

## Diagram Arsitektur

Berikut gambaran arsitektur lab K3s HA yang dibangun menggunakan Vagrant:

                    +----------------------+
                    |        LB            |
                    |  (HAProxy / Traefik) |
                    |  192.168.56.14       |
                    +----------+-----------+
                               |
               -----------------------------------------
               |                  |                    |
    +----------------+  +----------------+  +----------------+
    | k3s-master1    |  | k3s-master2    |  | k3s-master3    |
    | 192.168.56.11  |  | 192.168.56.12  |  | 192.168.56.13  |
    | Init Master    |  | Join Master    |  | Join Master    |
    +----------------+  +----------------+  +----------------+
