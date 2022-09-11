#!/bin/bash
# VPN Server Auto Script

    cd /usr/bin
    rm xp-tr
    rm xp-ss
    rm xp-vless
    rm xp-vmess

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