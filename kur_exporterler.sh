#!/bin/bash

echo "🔧 Node Exporter + DCGM Exporter Kurulum Scripti"

read -p "📛 Kullanıcı adı (örnek: mocky): " USER
read -p "🔌 Node Exporter portu (örnek: 2619): " NODE_PORT
read -p "🟡 DCGM Exporter portu (örnek: 2618): " DCGM_PORT

WORKDIR="/home/$USER/monitoring"
NODE_VERSION="1.9.1"
NODE_ARCHIVE="node_exporter-${NODE_VERSION}.linux-amd64.tar.gz"
NODE_DIR="node_exporter-${NODE_VERSION}.linux-amd64"

echo "📁 '$WORKDIR' dizini oluşturuluyor..."
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

echo "⬇️ Node Exporter indiriliyor..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/${NODE_ARCHIVE}
tar xvf ${NODE_ARCHIVE}
rm ${NODE_ARCHIVE}

echo "📝 Node Exporter systemd servis dosyası yazılıyor..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=$USER
ExecStart=$WORKDIR/$NODE_DIR/node_exporter --web.listen-address=:$NODE_PORT

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Node Exporter servisi başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl restart node_exporter
sudo systemctl status node_exporter --no-pager

echo "🐳 DCGM Exporter container başlatılıyor..."
docker run -d \
  --restart unless-stopped \
  --gpus all \
  -p ${DCGM_PORT}:9400 \
  --name dcgm-exporter \
  nvcr.io/nvidia/k8s/dcgm-exporter:latest

echo "✅ Kurulum tamamlandı."
