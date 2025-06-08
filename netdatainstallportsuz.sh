#!/bin/bash

set -e

read -p "🛠 Netdata kontrol sunucusunda kurulsun mu? (e/h): " KONTROL

if [[ "$KONTROL" =~ ^[eE]$ ]]; then
  echo "🛠 Netdata kontrol sunucusu kuruluyor..."
else
  echo "🛠 Netdata ajan kurulumu başlatılıyor..."
fi

# Netdata kurulumunu indir
cd /tmp
curl -s -L https://my-netdata.io/kickstart.sh -o netdata.sh

# Hatayı önlemek için direkt cd yapma yerine path açıkça belirtilmeli
sudo bash netdata.sh --dont-wait

# Konfig dosyasını bulup port ayarı yap
if [ -f /etc/netdata/netdata.conf ]; then
  echo "🔧 Varsayılan Netdata portu ayarlanıyor (19999)..."
  sudo sed -i 's/^\s*bind to = .*/  bind to = 0.0.0.0/' /etc/netdata/netdata.conf
  sudo sed -i 's/^\s*default port = .*/  default port = 19999/' /etc/netdata/netdata.conf

  echo "🔁 Netdata yeniden başlatılıyor..."
  sudo systemctl restart netdata
  sudo systemctl enable netdata
  echo "✅ Kurulum tamamlandı. Netdata http://<ip>:19999 adresinden erişilebilir."
else
  echo "❌ Hata: Netdata config dosyası bulunamadı. Kurulum tamamlanmamış olabilir."
fi
