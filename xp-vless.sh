#!/bin/bash

#AutoScript by Gugun
# Trojan
data=( `cat /etc/xray/vless-client.conf | grep '^Vless' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^Vless $user" "/etc/xray/vless-client.conf" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
if [[ $d1 -lt $d2  ]]; then
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[3].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[6].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/nontls.json | jq 'del(.inbounds[1].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/nontls.json.bak && mv /etc/xray/config/xray/nontls.json.bak /etc/xray/config/xray/nontls.json

sed -i "/\b$user\b/d" /etc/xray/vless-client.conf
systemctl restart xray@tls
systemctl restart xray@nontls
fi
done
