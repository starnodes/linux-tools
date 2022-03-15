# linux-tools
tools and scripts for linux systems

### change ssh port

```sh
echo 'port 34777' >> /etc/ssh/sshd_config
ufw allow 34777/tcp
systemctl restart sshd
```
