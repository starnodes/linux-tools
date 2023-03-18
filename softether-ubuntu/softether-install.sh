#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color
timedatectl set-timezone Europe/Moscow
sudo ufw allow 443,1194,5555/tcp && ufw allow 500,1701,4500/udp
sudo apt update
sudo apt install -y jq wget mc build-essential pkg-config cmake libncurses-dev libssl-dev zlib1g-dev libsodium-dev libpthread-stubs0-dev libncurses5-dev libreadline6-dev
sudo systemctl stop vpnserver.service

cd; \
SEversion=`wget -qO- https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | jq -r '.assets | .[].browser_download_url' | grep linux-x64-64bit | grep vpnserver`; \
wget -qO softethervpn.tar.gz ${SEversion}; \
tar xvf softethervpn.tar.gz; \
cd vpnserver; \
./.install.sh

mkdir /opt/vpnserver/
mv -b vpnserver vpncmd hamcore.se2 /opt/vpnserver/

printf "\nSelect Yes and create a local vpn bridge after installation by using New Tap Device "soft" (VPN will work faster this way), \nor select No if you want to use SecureNAT mode (easier to set up, but not as fast).\n\n"
PS3='Select number: '
options=("Yes" "No" "Quit")
select opt in "${options[@]}"
do
case $opt in
"Yes")
        printf "\nDNSMASQ setup.\n\n"
        apt install -y dnsmasq net-tools
        cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
        wget -qO /etc/dnsmasq.conf https://raw.githubusercontent.com/starnodes/linux-tools/main/softether-ubuntu/dnsmasq > /dev/null 2>&1
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
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        sysctl -p
        printf "\n${RED}Do not forget enable UFW!!!\n\n"
        printf "\n${RED}IMPORTANT !!!\n\n${NC}If you haven't created a local bridge yet with New Tap Device "soft" by using the SoftEther VPN Server Manager then DO IT. It is important that after you add the local bridge, you restart both dnsmasq and the vpnserver!\n\n"
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

PS3='Do you need to install IPTABLES and remove UFW for local bridge FIREWALL setup? (ssh port used 22 or 34777) | Select number: '
  options=("Yes" "No")
  select opt in "${options[@]}"
  do
    case $opt in
"Yes")
sudo apt-get remove --auto-remove ufw -y
sudo apt-get purge --auto-remove ufw -y
sudo rm -Rf /etc/ufw/
sudo apt-get install -y iptables
sudo systemctl enable iptables
sudo systemctl restart iptables
sudo iptables --version
echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sudo sysctl -p
WANIP=`wget -O - -q ifconfig.me/ip`
ETHWAN=`ip route get 8.8.8.8 | awk '{print $ 5}'`
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i tap_soft -o $ETHWAN -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 22,34777 -j ACCEPT
sudo iptables --policy INPUT DROP
sudo iptables --policy OUTPUT ACCEPT
sudo iptables --policy FORWARD DROP
sudo iptables -A INPUT -p tcp -m multiport --dports 443,1194,5555 -j ACCEPT
sudo iptables -A INPUT -p udp -m multiport --dports 500,1701,4500,1194 -j ACCEPT
sudo iptables -A INPUT -p udp -m multiport --dports 67,68 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.42.10.0/24 -o $ETHWAN -j MASQUERADE
sudo debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean false
EOF
sudo apt install -y iptables-persistent
sudo iptables-save > /etc/iptables/rules.v4
systemctl restart vpnserver dnsmasq
printf "\nFirewall is configured.\n\n"
break
    ;;
"No")
printf "\nSet up a firewall yourself. Interface "tap_soft", Network "10.42.10.0/24", PORTS used 443,1194,5555/tcp 500,1701,4500/udp 67,68/udp 22,34777/tcp\n\n"
break
esac
done
rm -rf $HOME/vpnserver
rm -f softethervpn.tar.gz
rm -f softether-install.sh
printf "\nAll done!!!\n\n"
printf "\nYou can configure and load iptables manually: iptables-restore < /etc/iptables/rules.v4\n\n"
