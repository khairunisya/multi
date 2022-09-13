#!/bin/bash

function import_data() {
    export RED="\033[0;31m"
    export GREEN="\033[0;32m"
    export YELLOW="\033[0;33m"
    export BLUE="\033[0;34m"
    export PURPLE="\033[0;35m"
    export CYAN="\033[0;36m"
    export LIGHT="\033[0;37m"
    export NC="\033[0m"
    export ERROR="[${RED} ERROR ${NC}]"
    export INFO="[${YELLOW} INFO ${NC}]"
    export FAIL="[${RED} FAIL ${NC}]"
    export OKEY="[${GREEN} OKEY ${NC}]"
    export PENDING="[${YELLOW} PENDING ${NC}]"
    export SEND="[${YELLOW} SEND ${NC}]"
    export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
    export RED_BG="\e[41m"
    export BOLD="\e[1m"
    export WARNING="${RED}\e[5m"
    export UNDERLINE="\e[4m"
}

import_data
IPNYA=$(wget --inet4-only -qO- https://ipinfo.io/ip)
ISPNYA=$(wget --inet4-only -qO- https://ipinfo.io/org | cut -d " " -f 2-100)
clear

read -p "Username : " username
username="$(echo ${username} | sed 's/ //g' | tr -d '\r' | tr -d '\r\n')"

# // Validate Input
if [[ $username == "" ]]; then
    clear
    echo -e "${FAIL} Silakan Masukan Username terlebih dahulu !"
    exit 1
fi

# // Checking User already on vps or no
if [[ "$(cat /etc/xray/trojan-client.conf | grep -w ${username})" != "" ]]; then
    clear
    echo -e "${FAIL} User [ ${Username} ] sudah ada !"
    exit 1
fi

# // Expired Date
read -p "Expired  : " Jumlah_Hari
exp=$(date -d "$Jumlah_Hari days" +"%Y-%m-%d")
hariini=$(date -d "0 days" +"%Y-%m-%d")

# // Get UUID
uuid=$(uuidgen)

# // Generate New UUID & Domain
domain=$(cat /etc/xray/domain.conf)


# // Getting Vmess port using grep from config
tls_port=$(cat /etc/xray/config/xray/tls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g')

# // Input Your Data to server
cat /etc/xray/config/xray/tls.json | jq '.inbounds[0].settings.clients += [{"password": "'${uuid}'","flow": "xtls-rprx-direct","email":"'${username}'","level": 0 }]' >/etc/xray/config/xray/tls.json.tmp && mv /etc/xray/config/xray/tls.json.tmp /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq '.inbounds[1].settings.clients += [{"password": "'${uuid}'","email":"'${username}'" }]' >/etc/xray/config/xray/tls.json.tmp && mv /etc/xray/config/xray/tls.json.tmp /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq '.inbounds[4].settings.clients += [{"password": "'${uuid}'","email":"'${username}'" }]' >/etc/xray/config/xray/tls.json.tmp && mv /etc/xray/config/xray/tls.json.tmp /etc/xray/config/xray/tls.json
echo -e "Trojan $username $exp $uuid" >>/etc/xray/trojan-client.conf

# // Make Configruation Link
grpc_link="trojan://${uuid}@${domain}:${tls_port}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc#${username}"
tcp_tls_link="trojan://${uuid}@${domain}:${tls_port}?security=tls&headerType=none&type=tcp#${username}"
ws_tls_link="trojan://${uuid}@${domain}:${tls_port}?path=%2Fjrtunnel-trojan&security=tls&type=ws#${username}"

# // Restarting XRay Service
systemctl restart xray@tls

# // Success
clear
echo -e "Trojan Account Details"
echo -e "==============================="
echo -e " ISP         = ${ISPNYA}"
echo -e " Remarks     = ${username}"
echo -e " IP          = ${IPNYA}"
echo -e " Address     = ${domain}"
echo -e " Port        = ${tls_port}"
echo -e " Password    = ${uuid}"
echo -e "==============================="
echo -e " GRPC TROJAN CONFIG LINK"
echo -e ' ```'${grpc_link}'```'
echo -e "==============================="
echo -e " TCP TLS TROJAN CONFIG LINK"
echo -e ' ```'${tcp_tls_link}'```'
echo -e "==============================="
echo -e " WS TLS TROJAN CONFIG LINK"
echo -e ' ```'${ws_tls_link}'```'
echo -e "==============================="
echo -e " Expired     = ${exp}"
echo -e "==============================="
