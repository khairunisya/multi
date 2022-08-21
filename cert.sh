#!/bin/bash

domain=$(cat /root/domain)
# Install Cert
apt install -y socat
# Menghentikan Port 443 & 80 jika berjalan
lsof -t -i tcp:80 -s tcp:listen | xargs kill >/dev/null 2>&1
lsof -t -i tcp:443 -s tcp:listen | xargs kill >/dev/null 2>&1
cd /root/
wget --inet4-only -O /root/.acme.sh/acme.sh "https://vpnsite.site/website/acme_sh"
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --register-account -m admin@vpnstores.com
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256 -ak ec-256 --ecc
    
systemctl daemon-reload
systemctl restart xray@tls
systemctl restart xray@nontls