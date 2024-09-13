#!/bin/bash
apt-get update
apt-get install -y ansible sshpass at


useradd ${USER}
echo "${USER}:${PASSWORD}" | chpasswd

echo "${instance1} server1" >> /etc/hosts
echo "${instance2} server2" >> /etc/hosts

mkdir /home/ansible /home/ansible/.ssh /home/ansible/variable /home/ansible/tasks /home/ansible/handler /home/ansible/cloudwatch_agent
touch /home/ansible/inventory

cat <<EOL > /home/ansible/inventory
    [webservers]
    server1 ansible_connection=ssh ansible_user=ansible
    server2 ansible_connection=ssh ansible_user=ansible
EOL

ssh-keygen -f /home/ansible/.ssh/id_rsa -N ""

chown -R ansible:ansible /home/ansible/

SERVERS=("server1" "server2")

for SERVER in "$${SERVERS[@]}"; do
    sudo -u "${USER}" sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no "${USER}@$SERVER" "cat >> /home/"${USER}"/.ssh/authorized_keys" < /home/"${USER}"/.ssh/id_rsa.pub
done

sed -i 's/^\s*#\?\s*PasswordAuthentication\s\+.*/PasswordAuthentication yes/' "/etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
systemctl restart ssh