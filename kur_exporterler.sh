#!/bin/bash

# Kullanıcıdan bilgi al
echo "🔧 Exporter Kurulum Scripti"
read -p "💛 Kullanıcı adı (ornegin: mocky): " USER
read -p "🔌 Node Exporter portu (ornegin: 2619): " NODE_PORT
read -p "🔌 DCGM Exporter portu (ornegin: 2618): " DCGM_PORT

# Monitoring dizinine geç
cd /home/${USER}
mkdir -p monitoring && cd monitoring

# NODE EXPORTER KURULUMU
echo "⬇️ Node Exporter indiriliyor..."
VERSIYON="1.9.1"
ARCHIV="node_exporter-${VERSIYON}.linux-amd64.tar.gz"
KLASOR="node_exporter-${VERSIYON}.linux-amd64"
wget -q https://github.com/prometheus/node_exporter/releases/download/v${VERSIYON}/${ARCHIV}
tar -xzf ${ARCHIV}
rm -f ${ARCHIV}

echo "📜 Node Exporter systemd servis dosyası yazılıyor..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=${USER}
ExecStart=/home/${USER}/monitoring/${KLASOR}/node_exporter --web.listen-address=:${NODE_PORT}

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Node Exporter servisi başlatılıyor..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl restart node_exporter
sudo systemctl status node_exporter --no-pager

# DOCKER VE NVIDIA TOOLKIT
echo "📁 Docker ve NVIDIA Container Toolkit kuruluyor..."
sudo apt-get update
sudo apt-get install -y docker.io nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# DCGM EXPORTER
echo "🐋 DCGM Exporter container başlatılıyor..."
docker run -d \
  --restart unless-stopped \
  --gpus all \
  -p ${DCGM_PORT}:9400 \
  --name dcgm-exporter \
  nvcr.io/nvidia/k8s/dcgm-exporter:latest

echo "✅ Kurulum tamamlandı."

# Not: Prometheus tarafına elle portlar eklenmeli.
