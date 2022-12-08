### Nftables install

```sh
sudo apt update
sudo apt install -y nftables
```

### Variables setup

```sh
ETHWAN=`ip route get 8.8.8.8 | awk '{print $ 5}'`
MYIPACCEPT="111.111.111.111/32"
MYPORTSACCEPT="22"
FULLPORTSACCEPT="80, 443, 10051"
```
### Install config

```sh
sudo tee /etc/nftables.conf > /dev/null <<EOF
#!/usr/sbin/nft -f

flush ruleset


table ip FIREWALLIPv4 {
    chain INCOMING {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iifname "lo" accept
        iifname "$ETHWAN" tcp dport { $FULLPORTSACCEPT } accept comment "Allow full accept"
        iifname "$ETHWAN" ip saddr { $MYIPACCEPT } tcp dport { $MYPORTSACCEPT } accept comment "Allow accept to SSH-server"
    }

    chain FORWARDING {
        type filter hook forward priority 0; policy drop;
    }

    chain OUTGOING {
        type filter hook output priority 0; policy accept;
    }
}
table ip6 FIREWALLIPv6 {
    chain INCOMING {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        ct state invalid drop
        iifname "lo" accept
        iifname "$ETHWAN" tcp dport { $FULLPORTSACCEPT } accept comment "Allow full accept"
    }

    chain FORWARDING {
        type filter hook forward priority 0; policy drop;
    }

    chain OUTGOING {
        type filter hook output priority 0; policy accept;
    }
}
EOF
```
### Nftables start

```sh
sudo systemctl enable nftables && sudo systemctl restart nftables
```

