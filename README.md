---

# 🚀 DevOps Kubernetes Lab

Repository ini menyediakan dua pendekatan implementasi Kubernetes untuk kebutuhan **development** dan **simulasi production environment**. Project ini dirancang untuk membantu memahami perbedaan arsitektur, kompleksitas, serta praktik DevOps modern dalam pengelolaan Kubernetes.

---

## 🎯 Objectives

* Memahami perbedaan arsitektur **single-node** dan **multi-node Kubernetes**
* Mensimulasikan environment **development vs production**
* Menerapkan praktik **Infrastructure as Code (IaC)** dan **automation**
* Meningkatkan pemahaman deployment dan orchestration pada Kubernetes

---

## 📁 Project Overview

### 🔹 Minikube (Single Node – Development Environment)

Minikube digunakan untuk menjalankan Kubernetes dalam satu node secara lokal dengan konfigurasi minimal.

**Karakteristik:**

* Single-node Kubernetes cluster
* Instalasi cepat dan sederhana
* Berjalan di atas container runtime (Docker)

**Use Case:**

* Pembelajaran dasar Kubernetes
* Testing resource seperti Deployment, Service, dan Ingress
* Development dan eksperimen lokal

**Pendekatan:**

* Tanpa automation (manual setup)
* Fokus pada penggunaan Kubernetes, bukan provisioning infrastruktur

---

### 🔹 K3s Cluster (Multi Node – Production Simulation)

K3s merupakan distribusi Kubernetes ringan yang digunakan untuk membangun cluster multi-node guna mensimulasikan environment production.

**Karakteristik:**

* Multi-node cluster (control-plane & worker)
* Lightweight dan efisien
* Mendekati arsitektur production

**Use Case:**

* Simulasi cluster production
* Pengujian workload terdistribusi
* Eksperimen High Availability (HA)

📌 **Implementation Reference:**
Untuk implementasi lengkap berbasis automation menggunakan Ansible, silakan lihat repository berikut:
👉 [https://github.com/endrycofr/Ansible_k3s](https://github.com/endrycofr/Ansible_k3s)

---

## ⚙️ DevOps Approach (IaC & Automation)

Implementasi K3s menggunakan pendekatan DevOps modern berbasis automation dan Infrastructure as Code.

**Tools yang digunakan:**

* **Vagrant** → Provisioning virtual machine
* **Ansible** → Konfigurasi dan deployment cluster

---

## 🔧 Automation dengan Ansible

Konfigurasi cluster dilakukan secara otomatis menggunakan Ansible, meliputi:

* Instalasi K3s pada seluruh node
* Setup control-plane dan worker
* Proses join cluster secara otomatis

**Keuntungan:**

* Environment dapat direplikasi (reproducible)
* Konsistensi konfigurasi antar node
* Mempermudah scaling dan maintenance

---

## ⚖️ Comparison

| Aspect           | Minikube               | K3s Cluster           |
| ---------------- | ---------------------- | --------------------- |
| Architecture     | Single-node            | Multi-node            |
| Setup Complexity | Low                    | Medium – High         |
| Automation       | None / Minimal         | Full (Ansible + IaC)  |
| Use Case         | Development & Learning | Production Simulation |
| Scalability      | Limited                | Scalable              |

---

## 🏗️ Architecture

**Minikube:**

```
VM / Host → Docker → Minikube → Kubernetes
```

**K3s Cluster:**

```
Multiple VM → Vagrant → Ansible → K3s → Kubernetes Cluster
```

---

## ⚠️ Notes

* **Minikube** digunakan untuk kebutuhan development dan pembelajaran
* **K3s Cluster** digunakan untuk simulasi environment production
* Project ini **tidak ditujukan untuk production real**, melainkan sebagai lab dan eksplorasi

---

## 🚀 DevOps Practices Implemented

Project ini mengimplementasikan beberapa praktik DevOps utama:

* Infrastructure as Code (IaC)
* Configuration Management (Ansible)
* Automated Provisioning
* Kubernetes Orchestration
* Environment Separation (Development vs Production Simulation)

---

Kalau kamu mau, saya bisa bantu bikin versi README yang “stand out untuk recruiter DevOps” 👍
