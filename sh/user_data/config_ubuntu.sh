#!/bin/bash

apt-get update -y
apt-get install nginx -y
apt-get install fail2ban -y
apt-get install git

#sshd config for ubuntu
sed -i "s/$(grep -m 1 "PermitRootLogin" /etc/ssh/sshd_config)/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/$(grep -m 1 "PasswordAuthentication" /etc/ssh/sshd_config)/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart sshd

#sudoers config for ubuntu
sed -i "s/$(grep "%sudo" /etc/sudoers)/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

adduser tutor-a --disabled-password --gecos ""
usermod -aG sudo tutor-a
mkdir /home/tutor-a/.ssh
touch /home/tutor-a/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" >> /home/tutor-a/.ssh/authorized_keys
chmod 700 /home/tutor-a/.ssh
chmod 600 /home/tutor-a/.ssh/authorized_keys
chown -R tutor-a:tutor-a /home/tutor-a/.ssh

repo_url="http://github.com/Beellzebub/page"
project_src="/home/ubuntu/project_src"

git clone "$repo_url" "$project_src"
mkdir /var/www/tutorial
cp "$project_src/html/index.html" "/var/www/tutorial/"
cp "$project_src/nginx/new_config" "/etc/nginx/sites-enabled/"
systemctl restart nginx
