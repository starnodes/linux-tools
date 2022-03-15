#!/bin/bash
timedatectl set-timezone Europe/Moscow
apt install -y pkg-config cmake libncurses-dev libssl-dev zlib1g-dev libsodium-dev libpthread-stubs0-dev libncurses5-dev libreadline6-dev
rm -rf $HOME/vpnserver
cd; \
SEversion=`wget -qO- https://api.github.com/repos/SoftEtherVPN/SoftEtherVPN_Stable/releases/latest | jq -r '.assets | .[].browser_download_url' | grep linux-x64-64bit | grep vpnserver` \
wget -qO softethervpn.tar.gz ${SEversion}; \
tar xvf softethervpn.tar.gz; \
cd vpnserver; \
./.install.sh

mv vpnserver vpncmd hamcore.se2 /usr/bin/

sudo tee /lib/systemd/system/vpnserver.service > /dev/null <<EOF
[Unit]
Description=SoftEther VPN Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/vpnserver start
ExecStop=/usr/bin/vpnserver stop

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload \
systemctl enable vpnserver \
systemctl restart vpnserver; \
journalctl -u vpnserver -f
