#!/bin/bash
# VPN Server Auto Script
# ===================================

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

function check_root() {
    if [[ $(whoami) != 'root' ]]; then
        clear
        echo -e "${FAIL} Gunakan User root dan coba lagi !"
        exit 1
    else
        export ROOT_CHK='true'
    fi
}

function check_architecture() {
    if [[ $(uname -m) == 'x86_64' ]]; then
        export ARCH_CHK='true'
    else
        clear
        echo -e "${FAIL} Architecture anda tidak didukung !"
        exit 1
    fi
}

function install_requirement() {
    #wget ${SCRIPT_URL}/cf.sh && chmod +x cf.sh && ./cf.sh
    hostname=jpvms.serverisp.xyz
    # Membuat Folder untuk menyimpan data utama
    mkdir -p /etc/xray/
    mkdir -p /etc/xray/core/
    mkdir -p /etc/xray/log/
    mkdir -p /etc/xray/config/
    echo "$hostname" >/etc/xray/domain.conf

    # Mengupdate repo dan hapus program yang tidak dibutuhkan
    apt update -y
    apt upgrade -y
    apt dist-upgrade -y
    apt autoremove -y
    apt clean -y

    # install wget and curl
apt -y install wget curl
apt -y install net-tools

# Install Requirements Tools
apt install ruby -y
apt install python -y
apt install make -y
apt install cmake -y
apt install coreutils -y
apt install rsyslog -y
apt install net-tools -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install sed -y
apt install gnupg -y
apt install gnupg1 -y
apt install bc -y
apt install jq -y
apt install apt-transport-https -y
apt install build-essential -y
apt install dirmngr -y
apt install libxml-parser-perl -y
apt install neofetch -y
apt install git -y
apt install lsof -y
apt install libsqlite3-dev -y
apt install libz-dev -y
apt install gcc -y
apt install g++ -y
apt install libreadline-dev -y
apt install zlib1g-dev -y
apt install libssl-dev -y
apt install libssl1.0-dev -y
apt install dos2unix -y

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

    #  Menghapus apache2 nginx sendmail ufw firewall dan exim4 untuk menghindari port nabrak
    apt remove --purge nginx apache2 sendmail ufw firewalld exim4 -y >/dev/null 2>&1
    apt autoremove -y
    apt clean -y

    # Menginstall paket yang di butuhkan
    apt install build-essential apt-transport-https -y
    apt install zip unzip nano net-tools make git lsof wget curl jq bc gcc make cmake neofetch htop libssl-dev socat sed zlib1g-dev libsqlite3-dev libpcre3 libpcre3-dev libgd-dev -y
	apt-get install uuid-runtime

    # Menghentikan Port 443 & 80 jika berjalan
    lsof -t -i tcp:80 -s tcp:listen | xargs kill >/dev/null 2>&1
    lsof -t -i tcp:443 -s tcp:listen | xargs kill >/dev/null 2>&1

    # Membuat sertifikat letsencrypt untuk xray
    rm -rf /root/.acme.sh
    mkdir /root/.acme.sh
    curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --issue -d jpvms.serverisp.xyz -d jptrws.serverisp.xyz -d jpvless.serverisp.xyz --standalone -k ec-256 -ak ec-256
    echo -e " [INFO] Successfully"
    sleep 1

    # Menyetting waktu menjadi waktu WIB
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

    # Install nginx
    apt-get install libpcre3 libpcre3-dev zlib1g-dev dbus -y
    echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" |
        sudo tee /etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt update
    apt install nginx -y
    wget -O /etc/nginx/nginx.conf "${SCRIPT_URL}/nginx.conf"
    wget -O /etc/nginx/conf.d/xray.conf "${SCRIPT_URL}/xray.conf"
    rm -rf /etc/nginx/conf.d/default.conf
    systemctl enable nginx
    mkdir -p /home/vps/public_html
    chown -R www-data:www-data /home/vps/public_html
    chmod -R g+rw /home/vps/public_html
    echo "<pre>Setup BY Jrtunnel</pre>" >/home/vps/public_html/index.html
    systemctl start nginx

    # Install Vnstat
    NET=$(ip -o $ANU -4 route show to default | awk '{print $5}')
    apt -y install vnstat
    /etc/init.d/vnstat restart
    apt -y install libsqlite3-dev
    wget https://humdi.net/vnstat/vnstat-2.9.tar.gz
    tar zxvf vnstat-2.9.tar.gz
    cd vnstat-2.9
    ./configure --prefix=/usr --sysconfdir=/etc && make && make install
    cd
    vnstat -u -i $NET
    sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
    chown vnstat:vnstat /var/lib/vnstat -R
    systemctl enable vnstat
    /etc/init.d/vnstat restart
    rm -f /root/vnstat-2.9.tar.gz
    rm -rf /root/vnstat-2.9

    # Install Xray
    wget --inet4-only -O /etc/xray/core/xray.zip "${SCRIPT_URL}/xray.zip"
    cd /etc/xray/core/
    unzip -o xray.zip
    rm -f xray.zip
    cd /root/
    mkdir -p /etc/xray/log/xray/
    mkdir -p /etc/xray/config/xray/
    wget --inet4-only -qO- "${SCRIPT_URL}/tls.json" | jq '.inbounds[0].streamSettings.xtlsSettings.certificates += [{"certificateFile": "'/root/.acme.sh/${hostname}_ecc/fullchain.cer'","keyFile": "'/root/.acme.sh/${hostname}_ecc/${hostname}.key'"}]' >/etc/xray/config/xray/tls.json
    wget --inet4-only -qO- "${SCRIPT_URL}/nontls.json" >/etc/xray/config/xray/nontls.json
    wget --inet4-only -O /etc/systemd/system/xray@.service "${SCRIPT_URL}/xray_service"
    systemctl daemon-reload
    systemctl stop xray@tls
    systemctl disable xray@tls
    systemctl enable xray@tls
    systemctl start xray@tls
    systemctl restart xray@tls
    systemctl stop xray@nontls
    systemctl disable xray@nontls
    systemctl enable xray@nontls
    systemctl start xray@nontls
    systemctl restart xray@nontls

    # // Download welcome
    echo "clear" >>.profile
    echo "neofetch" >>.profile
    echo "echo by Jrtunnel" >>.profile

    # // Install smtp

    curl https://rclone.org/install.sh | bash
    printf "q\n" | rclone config
    wget -O /root/.config/rclone/rclone.conf "${SCRIPT_URL}/rclone.conf"
    git clone  https://github.com/magnific0/wondershaper.git
    cd wondershaper
    make install
    cd
    rm -rf wondershaper
    echo > /home/limit
    apt install msmtp-mta ca-certificates bsd-mailx -y
    wget --inet4-only -O /etc/msmtprc "${SCRIPT_URL}/msmtprc"
    chown -R www-data:www-data /etc/msmtprc

    # // Install python2
    apt install python2 -y >/dev/null 2>&1

    # // Download menu
    cd /usr/bin
    wget --inet4-only -O addvmess "${SCRIPT_URL}/addvmess.sh"
    chmod +x addvmess
    wget --inet4-only -O addvless "${SCRIPT_URL}/addvless.sh"
    chmod +x addvless
    wget --inet4-only -O addtrojan "${SCRIPT_URL}/addtrojan.sh"
    chmod +x addtrojan
    wget --inet4-only -O delvmess "${SCRIPT_URL}/delvmess.sh"
    chmod +x delvmess
    wget --inet4-only -O delvless "${SCRIPT_URL}/delvless.sh"
    chmod +x delvless
    wget --inet4-only -O deltrojan "${SCRIPT_URL}/deltrojan.sh"
    chmod +x deltrojan
    wget --inet4-only -O renewvmess "${SCRIPT_URL}/renewvmess.sh"
    chmod +x renewvmess
    wget --inet4-only -O renewvless "${SCRIPT_URL}/renewvless.sh"
    chmod +x renewvless
    wget --inet4-only -O renewtrojan "${SCRIPT_URL}/renewtrojan.sh"
    chmod +x renewtrojan
    wget --inet4-only -O xray-cert "${SCRIPT_URL}/cert.sh"
    chmod +x xray-cert
    wget --inet4-only -O menu "${SCRIPT_URL}/menu.sh"
    chmod +x menu
    wget --inet4-only -O addwg "${SCRIPT_URL}/addwg.sh"
    chmod +x addwg
    wget --inet4-only -O delwg "${SCRIPT_URL}/delwg.sh"
    chmod +x delwg
    wget --inet4-only -O renewwg "${SCRIPT_URL}/renewwg.sh"
    chmod +x renewwg
    
    wget --inet4-only -O addss "${SCRIPT_URL}/addss.sh"
    chmod +x addss
    wget --inet4-only -O delss "${SCRIPT_URL}/delss.sh"
    chmod +x delss

    wget --inet4-only -O autobackup "${SCRIPT_URL}/autobackup.sh"
    chmod +x autobackup
    wget --inet4-only -O backup "${SCRIPT_URL}/backup.sh"
    chmod +x backup
    wget --inet4-only -O bckp "${SCRIPT_URL}/bckp.sh"
    chmod +x bckp
    wget --inet4-only -O restore "${SCRIPT_URL}/restore.sh"
    chmod +x restore
    cd

    cd /usr/bin
    wget -O xp "https://raw.githubusercontent.com/khairunisya/multi/main/xp.sh"

    chmod +x xp
    cd


    echo "0 5 * * * root clearlog && reboot" >> /etc/crontab
    echo "0 0 * * * root xp" >> /etc/crontab
    cd

    #installwg
    wget https://raw.githubusercontent.com/khairunisya/multi/main/wg.sh && chmod +x wg.sh && screen -S wg ./wg.sh

    #install bbr
    wget https://raw.githubusercontent.com/khairunisya/multi/main/bbr.sh && chmod +x bbr.sh && screen -S wg ./bbr.sh

    cd

    mkdir /home/trojan
    mkdir /home/vmess
    mkdir /home/vless
    mkdir /home/shadowsocks
    cat >/home/vps/public_html/trojan.json <<END
{
    "TCP TLS" : "443",
    "WS TLS" : "443"
}
END
    cat >/home/vps/public_html/vmess.json <<END
    {
        "WS TLS" : "443",
        "WS Non TLS" : "80"
    }
END
    cat >/home/vps/public_html/vless.json <<END
    {
        "WS TLS" : "443",
        "WS Non TLS" : "80"
    }
END
    cat >/home/vps/public_html/ss.json <<END
    {
        "WS TLS" : "443",
        "GRPC" : "443"
    }
END

    touch /etc/xray/trojan-client.conf
    touch /etc/xray/vmess-client.conf
    touch /etc/xray/vless-client.conf
    touch /etc/xray/ss-client.conf

	# // Force create folder for fixing account wasted
	mkdir -p /etc/xray/xray-cache/

    # // Setting environment
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/etc/xray/core:' >/etc/environment
    source /etc/environment

    rm -rf /root/setup.sh
    echo "Penginstallan Berhasil"
}

function main() {
    import_string
    check_root
    check_architecture
    install_requirement
}

main
