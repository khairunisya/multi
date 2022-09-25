# xray-install
apt-get update && apt-get upgrade -y && update-grub && sleep 2 && reboot

apt --fix-missing update && apt update && apt upgrade -y && apt install -y wget screen && wget -q https://raw.githubusercontent.com/khairunisya/multi/main/setup.sh && chmod +x setup.sh && screen -S setup ./setup.sh