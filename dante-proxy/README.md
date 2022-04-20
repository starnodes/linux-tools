## Настройка SOCKS5 прокси на сервере linux

### quick start

#### Dante proxy server auto install

```sh
sudo wget -qO $HOME/dante-install.sh https://raw.githubusercontent.com/starnodes/linux-tools/main/dante-proxy/dante-install.sh
chmod +x $HOME/dante-install.sh && $HOME/dante-install.sh
```

After installation:

If you need authentication, use this option in /etc/danted.conf

```sh
socksmethod: username
```

And create users:

```sh
useradd --shell /usr/sbin/nologin proxy_user_01
echo -e "password_user_01\npassword_user_01" | passwd proxy_user_01
```
