# linux-tools
tools and scripts for linux systems

### change ssh port

```sh
sudo sed -i 's/#Port 22/Port 34777/' /etc/ssh/sshd_config
ufw allow 34777/tcp
systemctl restart sshd
```
### change timezone

Ubuntu
```sh
timedatectl set-timezone Europe/Moscow
apt -y install chrony
systemctl restart chrony && systemctl enable chrony
```

RHEL

```sh
timedatectl set-timezone Europe/Moscow
yum -y install chrony
systemctl restart chronyd && systemctl enable chronyd
```

### swap usage change

```sh
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl -p
```

### required packages

```sh
sudo apt update
sudo apt install htop mc curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony net-tools liblz4-tool iotop nload -y
```

### ssh root login enable + random root password generation

```sh
PASS=`openssl rand -base64 15`
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo -e "$PASS\n$PASS" | passwd root
echo $PASS
```
### sftp file download

make archive

```sh
tar cfvz example.tar.gz exampledir
```

download archive

```sh
port=22
srv_ip=111.111.111.111
sftp -P $port root@$srv_ip:/home/example.tar.gz /home
tar xvf example.tar.gz
```

### Check for Listening Ports

```sh
netstat -tulpn
```

-t - Show TCP ports.

-u - Show UDP ports.

-n - Show numerical addresses instead of resolving hosts.

-l - Show only listening ports.

-p - Show the PID and name of the listener’s process. This information is shown only if you run the command as root or sudo user.

### Linux performance test

```sh
wget -qO- bench.sh|bash
```

#### Disk speed

```sh
iotop
```
#### Network speed

```sh
nload
```

### SElinux permissive Centos

```sh
sudo setenforce 0
sudo sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config
```
