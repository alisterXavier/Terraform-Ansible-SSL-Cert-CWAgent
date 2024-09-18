#!/bin/bash

apt-get update
apt-get install certbot python3-certbot-dns-route53 python3-certbot-apache apache2 at -y

useradd ansible
echo "ansible:typewriter" | chpasswd

mkdir -p /root/.aws
touch /root/.aws/config
cat << EOL > ~/.aws/config
    [default]
    aws_access_key_id = ${aws_access_key_id}
    aws_secret_access_key = ${aws_secret_access_key}
    region = us-east-1
    output = json
EOL

mkdir /home/ansible
mkdir /home/ansible/.ssh

chown ansible:ansible -R /home/ansible

echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null


sed -i 's/^\s*#\?\s*PasswordAuthentication\s\+.*/PasswordAuthentication yes/' "/etc/ssh/sshd_config.d/60-cloudimg-settings.conf"

systemctl restart ssh
systemctl enable ssh