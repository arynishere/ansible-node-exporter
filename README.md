# ansible-node-exporter
## For installation node exporter 

To use this script, you need to install Ansible in advance. I have put a script for you in this repo, which you can install using the following command:
```
cd ansible-node-exporter

bash ansibleinstall.sh
```
# set ansible hosts
## Hosts
To add hosts, proceed as follows:

```
[node-exporter]
"domain or host IP" ansible_ssh_port="portnumber" ansible_ssh_user="username" ansible_ssh_pass="password"
```
you can add many ip or domain like this command and save name file "hosts"

