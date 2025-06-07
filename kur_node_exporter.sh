#!/bin/bash

echo "🔧 Node Exporter Kurulum Scripti"
read -p "📛 Kullanıcı adı (örnek: mocky): " USER
read -p "🔌 Hangi portta çalışsın? (örnek: 2619): " PORT

VERSIYON="1.9.1"
ARCHIV="node_exporter-${VERSIYON}.linux-amd64.tar.gz"
KLASOR="node_exporter-${VERSIYON}.linux-amd64"

echo "⬇️ Node Exporter indiriliyor..."
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSIYON}/${ARCHIV}
tar xvf ${ARCHIV}
rm ${ARCHIV}

echo "📝 systemd servis dosyası yazılıyor..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=${USER}
ExecStart=/home/${USER}/${KLASOR}/node_exporter --web.listen-address=:${PORT}

[Install]
WantedBy=default.target
EOF

echo "🔄 Servis başlatılıyor..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl restart node_exporter
sudo systemctl status node_exporter --no-pager
