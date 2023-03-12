## Установка SoftEther VPN Server на Ubuntu 20.04

### quick start

ports for opening

```sh
TCP Ports: 443, 992 and 5555
UDP: 500 and 4500 // l2tp ipsec
UDP: 1194 // ovpn
```

Install VPN Server

```sh
sudo wget -qO $HOME/softether-install.sh https://raw.githubusercontent.com/starnodes/linux-tools/main/softether-ubuntu/softether-install.sh
chmod +x $HOME/softether-install.sh && $HOME/softether-install.sh
```

Now you need to download latest verion of SoftEther VPN Server Manager

https://www.softether-download.com/en.aspx

Install program component "SoftEther VPN Server Manager" only.

Connect to server_ip:5555 and change your master password.

Configure VPN server.
