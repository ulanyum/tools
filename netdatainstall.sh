#!/bin/bash

echo "🛠 Netdata hangi portta çalışsın? (örnek: 2419): "
read PORT

echo "⬇️ Netdata kurulumu başlatılıyor..."
curl -sSL https://raw.githubusercontent.com/netdata/netdata/master/packaging/installer/kickstart.sh -o netdata.sh
bash netdata.sh --dont-wait

CONFIG_PATH="/etc/netdata/netdata.conf"

if [ -f "$CONFIG_PATH" ]; then
    echo "⚙️ Konfigürasyon düzenleniyor..."
    sudo sed -i "s/^#\? bind to =.*/bind to = 0.0.0.0/" "$CONFIG_PATH"
    sudo sed -i "s/^#\? default port =.*/default port = ${PORT}/" "$CONFIG_PATH"
    sudo systemctl restart netdata
    echo "✅ Netdata ${PORT} portunda çalışıyor."
else
    echo "❌ Hata: Netdata config dosyası bulunamadı. Kurulum tamamlanmamış olabilir."
fi
