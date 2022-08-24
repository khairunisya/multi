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
if [[ "$(cat /etc/xray/vless-client.conf | grep -w ${username})" != "" ]]; then
    clear
    echo -e "${FAIL} User [ ${username} ] sudah ada !"
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
nontls_port=$(cat /etc/xray/config/xray/nontls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g')

# // Input Your Data to server
cat /etc/xray/config/xray/tls.json | jq '.inbounds[3].settings.clients += [{"id": "'${uuid}'","email": "'${username}'"}]' >/etc/xray/config/xray/tls.json.tmp && mv /etc/xray/config/xray/tls.json.tmp /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/tls.json | jq '.inbounds[6].settings.clients += [{"id": "'${uuid}'","email": "'${username}'"}]' >/etc/xray/config/xray/tls.json.tmp && mv /etc/xray/config/xray/tls.json.tmp /etc/xray/config/xray/tls.json
cat /etc/xray/config/xray/nontls.json | jq '.inbounds[1].settings.clients += [{"id": "'${uuid}'","email": "'${username}'"}]' >/etc/config/config/xray/nontls.json.tmp && mv /etc/xray/config/xray/nontls.json.tmp /etc/xray/config/xray/nontls.json
echo -e "Vless $username $exp $uuid" >>/etc/xray/vless-client.conf

# // Vless Link
vless_nontls="vless://${uuid}@${domain}:${nontls_port}?path=%2Fvless&security=none&encryption=none&type=ws#${username}"
vless_tls="vless://${uuid}@${domain}:${tls_port}?path=%2Fvless&security=tls&encryption=none&type=ws#${username}"
vless_grpc="vless://${uuid}@${domain}:${tls_port}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=Vless-GRPC#${username}"

# // Restarting XRay Service
systemctl restart xray@tls
systemctl restart xray@nontls

# // Success
clear
echo -e "Vless Account Details"
echo -e "==============================="
echo -e " ISP         = ${ISPNYA}"
echo -e " Remarks     = ${username}"
echo -e " IP          = ${IPNYA}"
echo -e " Address     = ${domain}"
echo -e " Port TLS    = ${tls_port}"
echo -e " Port NonTLS = ${nontls_port}"
echo -e " UUID        = ${uuid}"
echo -e "==============================="
echo -e " GRPC VLESS CONFIG LINK"
echo -e ' ```'${vless_grpc}'```'
echo -e "==============================="
echo -e " WS TLS VLESS CONFIG LINK"
echo -e ' ```'${vless_tls}'```'
echo -e "==============================="
echo -e " WS NTLS VLESS CONFIG LINK"
echo -e ' ```'${vless_nontls}'```'
echo -e "==============================="
echo -e " Expired     = ${exp}"
echo -e "==============================="
