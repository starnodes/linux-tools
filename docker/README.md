## DOCKER INSTALLATION

### DOCKER INSTALL

```sh
sudo apt install wget jq ca-certificates gnupg -y
source /etc/*-release
rm -f /usr/share/keyrings/docker-archive-keyring.gpg
wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
```
### DOCKER-COMPOSE INSTALL

```sh
docker_compose_version=`wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name"`
sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-`uname -s`-`uname -m`"
sudo chmod +x /usr/bin/docker-compose
docker-compose -v
```

### UNINSALL

```sh
sudo systemctl stop docker.service docker.socket
sudo systemctl disable docker.service docker.socket
sudo rm -rf `systemctl cat docker.service | grep -oPm1 "(?<=^#)([^%]+)"` `systemctl cat docker.socket | grep -oPm1 "(?<=^#)([^%]+)"` /usr/bin/docker-compose
sudo apt purge docker-engine docker docker.io docker-ce docker-ce-cli -y
sudo apt autoremove --purge docker-engine docker docker.io docker-ce -y
sudo apt autoclean
sudo rm -rf /var/lib/docker /etc/appasudo rmor.d/docker
sudo groupdel docker
sudo rm -rf /etc/docker /usr/bin/docker /usr/libexec/docker /usr/libexec/docker/cli-plugins/docker-buildx /usr/libexec/docker/cli-plugins/docker-scan /usr/libexec/docker/cli-plugins/docker-app /usr/share/keyrings/docker-archive-keyring.gpg
```
