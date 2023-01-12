# linux-tools
tools and scripts for linux systems

### change ssh port

```sh
ssh_port=1022
sudo sed -i 's/#Port 22/Port $ssh_port/' /etc/ssh/sshd_config
systemctl restart sshd
```

### Rust install

```sh
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env" && \
echo -e "\n$(cargo --version).\n"
```

### NodeJS + npm install

```sh
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
sudo apt-get install nodejs -y && \
echo -e "\nnodejs > $(node --version).\nnpm  >>> v$(npm --version).\n"
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

http share folder 

```sh
python3 -m http.server 8181
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
