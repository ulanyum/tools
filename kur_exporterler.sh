#!/bin/bash

echo "🔧 Exporter Kurulum Scripti"

read -p "📛 Kullanıcı adı (örnek: mocky): " USER
read -p "🖥 Node Exporter portu (örnek: 2619): " NODE_PORT
read -p "📊 DCGM Exporter portu (örnek: 2618): " DCGM_PORT

echo "📁 monitoring klasörü oluşturuluyor..."
cd /home/$USER
mkdir -p monitoring && cd monitoring

### --- NODE EXPORTER ---
NODE_VER="1.9.1"
NODE_ARCHIVE="node_exporter-${NODE_VER}.linux-amd64.tar.gz"
NODE_DIR="node_exporter-${NODE_VER}.linux-amd64"

echo "⬇️ Node Exporter indiriliyor..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_VER}/${NODE_ARCHIVE}
tar xvf ${NODE_ARCHIVE}
rm ${NODE_ARCHIVE}

echo "📝 Node Exporter systemd servis dosyası yazılıyor..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=${USER}
ExecStart=/home/${USER}/monitoring/${NODE_DIR}/node_exporter --web.listen-address=:${NODE_PORT}

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Node Exporter servisi başlatılıyor..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl restart node_exporter
sudo systemctl status node_exporter --no-pager

### --- DOCKER ve NVIDIA TOOLKIT ---
echo "🐳 Docker ve NVIDIA Container Toolkit kuruluyor..."
sudo apt-get update
sudo apt-get install -y docker.io curl gnupg

# NVIDIA Container Toolkit Kurulumu (Ubuntu 20.04 / 22.04)
echo "🔑 NVIDIA GPG anahtarı ve repo ekleniyor..."
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's|^deb |deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] |' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

echo "⚙️ NVIDIA runtime docker'a entegre ediliyor..."
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

### --- DCGM EXPORTER ---
echo "🐳 DCGM Exporter container başlatılıyor..."
docker pull nvcr.io/nvidia/k8s/dcgm-exporter:latest
docker run -d \
  --restart unless-stopped \
  --gpus all \
  -p ${DCGM_PORT}:9400 \
  --name dcgm-exporter \
  nvcr.io/nvidia/k8s/dcgm-exporter:latest

echo "✅ Kurulum tamamlandı."
