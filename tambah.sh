#!/bin/bash
# VPN Server Auto Script


function import_string() {
    export SCRIPT_URL='https://raw.githubusercontent.com/khairunisya/multi/main/'
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


    cd /usr/bin
    rm -f xp-tr
    rm -f xp-ss
    rm -f xp-vless
    rm -f xp-vmess

    cd



    cd /usr/bin
    wget -O xp-tr "https://raw.githubusercontent.com/khairunisya/multi/main/xp-tr.sh"
    wget -O xp-ss "https://raw.githubusercontent.com/khairunisya/multi/main/xp-ss.sh"
    wget -O xp-vless "https://raw.githubusercontent.com/khairunisya/multi/main/xp-vless.sh"
    wget -O xp-vmess "https://raw.githubusercontent.com/khairunisya/multi/main/xp-vmess.sh"


    chmod +x xp-tr
    chmod +x xp-ss
    chmod +x xp-vless
    chmod +x xp-vmess
    cd
    sed -i -e 's/\r$//' xp-tr
    sed -i -e 's/\r$//' xp-ss
    sed -i -e 's/\r$//' xp-vless
    sed -i -e 's/\r$//' xp-vmess
    cd

    echo "0 0 * * * root clearlog && reboot" >> /etc/crontab
    echo "0 0 * * * root xp-tr" >> /etc/crontab
    echo "0 0 * * * root xp-vless" >> /etc/crontab
    echo "0 0 * * * root xp-vmess" >> /etc/crontab
    cd

     reboot