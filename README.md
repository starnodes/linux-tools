# linux-tools
tools and scripts for linux systems

### change ssh port

```sh
sudo sed -i 's/#Port 22/Port 34777/' /etc/ssh/sshd_config
ufw allow 34777/tcp
systemctl restart sshd
```
### ssh root login enable

```sh
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo -e "linuxpassword\nlinuxpassword" | passwd root
```
### sftp file download

make archive

tar cfvz example.tar.gz exampledir

download archive

```sh
port=22
srv_ip=111.111.111.111
sftp -P $port root@$srv_ip:/home/example.tar.gz /home
tar xvf example.tar.gz
```
