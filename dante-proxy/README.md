## Настройка файла подкачки на сервере linux

### quick start

#### Dante proxy server auto install

Add user after installation (proxy_user_01 :: password_user_01):

```sh
useradd --shell /usr/sbin/nologin proxy_user_01
echo -e "password_user_01\npassword_user_01" | passwd proxy_user_01
```

```sh
sudo wget -qO $HOME/dante-install.sh https://raw.githubusercontent.com/starnodes/linux-tools/main/dante-proxy/dante-install.sh
chmod +x $HOME/dante-install.sh && $HOME/dante-install.sh
```
