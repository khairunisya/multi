#!/bin/bash

#AutoScript by Gugun
# Trojan
data=( `cat /etc/xray/vmess-client.conf | grep '^Vmess' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^Vmess $user" "/etc/xray/vmess-client.conf" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
if [[ $d1 -eq $d2  ]]; then
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[2].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[5].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/nontls.json | jq 'del(.inbounds[0].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/nontls.json.bak && mv /etc/xray/config/xray/nontls.json.bak /etc/xray/config/xray/nontls.json
rm -f /etc/xray/xray-cache/vmess-tls-gun-$user.json /etc/xray/xray-cache/vmess-tls-ws-$user.json /etc/xray/xray-cache/vmess-nontls-$user.json
sed -i "/\b$user\b/d" /etc/xray/vmess-client.conf
systemctl restart xray@tls
systemctl restart xray@nontls
fi
done
