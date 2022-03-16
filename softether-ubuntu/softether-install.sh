#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
timedatectl set-timezone Europe/Moscow
sudo ufw allow 443,1194,5555/tcp && ufw allow 500,1701,4500/udp
sudo apt update
sudo apt install -y jq wget mc build-essential pkg-config cmake libncurses-dev libssl-dev zlib1g-dev libsodium-dev libpthread-stubs0-dev libncurses5-dev libreadline6-dev
sudo systemctl stop vpnserver.service

rm -rf $HOME/vpnserver
cd; \
SEversion=`wget -qO- https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | jq -r '.assets | .[].browser_download_url' | grep linux-x64-64bit | grep vpnserver`; \
wget -qO softethervpn.tar.gz ${SEversion}; \
tar xvf softethervpn.tar.gz; \
cd vpnserver; \
./.install.sh

mkdir /opt/vpnserver/
mv -b vpnserver vpncmd hamcore.se2 /opt/vpnserver/

PS3='First connect to your SoftEther server with Manager and create local vpn bridge with New Tap Device "soft"! If unsure or are using SecureNAT, select No. Select number: '
options=("Yes" "No" "Quit")
select opt in "${options[@]}"
do
case $opt in
"Yes")
        printf "\nDNSMASQ setup.\n\n"
        apt install -y dnsmasq net-tools
        cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
        wget -qO /etc/dnsmasq.conf https://raw.githubusercontent.com/starnodes/linux-tools/main/softether-ubuntu/dnsmarq > /dev/null 2>&1
        printf "\nSystem daemon setup. Registering changes...\n\n"
        wget -qO /etc/init.d/vpnserver https://raw.githubusercontent.com/starnodes/linux-tools/main/softether-ubuntu/service-bridge > /dev/null 2>&1
        chmod 755 /etc/init.d/vpnserver
        update-rc.d vpnserver defaults > /dev/null 2>&1
        printf "\nSoftEther VPN Server should now start as a system service from now on.\n\n"
        systemctl start vpnserver
        systemctl restart dnsmasq
        systemctl enable dnsmasq
        sleep 10
        cp /opt/vpnserver/vpn_server.config /opt/vpnserver/vpn_server.config.bak
        sed -i '1,50s/bool Disabled false/bool Disabled true/' /opt/vpnserver/vpn_server.config
        sed -i 's/bool DisableNatTraversal false/bool DisableNatTraversal true/' /opt/vpnserver/vpn_server.config
        sed -i 's/bool DisableUdpAcceleration false/bool DisableUdpAcceleration true/' /opt/vpnserver/vpn_server.config
        systemctl restart vpnserver
        systemctl is-active --quiet vpnserver && echo "Service vpnserver is running.\n\n"
        printf "\nIPv4 Forward activation\n\n"
        ufw allow 67,68/udp
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        sysctl -p
        printf "\n${RED}Do not forget enable UFW!!!\n\n"
        printf "\n${RED}IMPORTANT !!!\n\n${NC} If you haven't created a local bridge yet with New Tap Device "soft" by using the SoftEther VPN Server Manager then DO IT. It is important that after you add the local bridge, you restart both dnsmasq and the vpnserver!\n\n"
	      sleep 5s
        break
            ;;
        "No")
	       printf "\nSystem daemon setup. Registering changes...\n\n"
        wget -qO /etc/init.d/vpnserver https://raw.githubusercontent.com/starnodes/linux-tools/main/softether-ubuntu/service-SN > /dev/null 2>&1
        chmod 755 /etc/init.d/vpnserver
        update-rc.d vpnserver defaults > /dev/null 2>&1
        printf "\nSoftEther VPN Server should now start as a system service from now on.\n\n"
        systemctl start vpnserver
        systemctl is-active --quiet vpnserver && echo "Service vpnserver is running."
	      printf "\n${RED}Do not forget enable UFW!!!\n\n"
        printf "\n${RED}!!! IMPORTANT !!!\n\n${NC} Plese configure the server with SecureNAT, use the SoftEther VPN Server Manager!!!\n\n"
        break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
exit 0
