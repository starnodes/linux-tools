#!/bin/bash
sudo apt install -y dante-server

ETHWAN=`ip route get 8.8.8.8 | awk '{print $ 5}'`
ufw allow 1080/tcp

sudo tee /etc/danted.conf > /dev/null <<EOF
logoutput: /var/log/socks.log
internal: $ETHWAN port = 1080
external: $ETHWAN
clientmethod: none
socksmethod: none
user.privileged: root
user.notprivileged: nobody

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
client block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
socks pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
socks block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
EOF

sudo tee /lib/systemd/system/danted.service > /dev/null <<EOF
[Unit]
Description=SOCKS (v4 and v5) proxy daemon (danted)
Documentation=man:danted(8) man:danted.conf(5)
After=network.target

[Service]
Type=simple
PIDFile=/run/danted.pid
ExecStart=/usr/sbin/danted
ExecStartPre=/bin/sh -c ' \
        uid=`sed -n -e "s/[[:space:]]//g" -e "s/#.*//" -e "/^user\\.privileged/{s/[^:]*://p;q;}" /etc/danted.conf`; \
        if [ -n "$uid" ]; then \
                touch /var/run/danted.pid; \
                chown $uid /var/run/danted.pid; \
        fi \
        '
PrivateTmp=yes
InaccessibleDirectories=/boot /home /media /mnt /opt /root
ReadOnlyDirectories=/bin /etc /lib -/lib64 /sbin /usr
DeviceAllow=/dev/null rw

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart danted && sudo systemctl enable danted
