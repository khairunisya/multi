#!/bin/bash

#AutoScript by Gugun
# Trojan
data=( `cat /etc/xray/trojan-client.conf | grep '^Trojan' | cut -d ' ' -f 2`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^Trojan $user" "/etc/xray/trojan-client.conf" | cut -d ' ' -f 3)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
if [[ $d1 -lt $d2  ]]; then
printf "y\n" | cp /etc/xray/config/xray/tls.json /etc/xray/xray-cache/cache-nya.json
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[0].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[1].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq 'del(.inbounds[4].settings.clients[] | select(.email == "'${user}'"))' >/etc/xray/config/xray/tls.json.bak && mv /etc/xray/config/xray/tls.json.bak /etc/xray/config/xray/tls.json

sed -i "/\b$user\b/d" /etc/xray/trojan-client.conf
systemctl restart xray@tls
fi
done
