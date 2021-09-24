#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx -y
sudo apt-get install fail2ban -y
sudo apt-get install git

#sshd config for ubuntu
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo adduser tutor-a
sudo usermod -aG sudo tutor-a
sudo mkdir /home/tutor-a/.ssh
sudo touch /home/tutor-a/.ssh/authorized_keys
sudo echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" >> /home/tutor-a/.ssh/authorized_keys
sudo chmod 700 /home/tutor-a/.ssh
sudo chmod 600 /home/tutor-a/.ssh/authorized_keys
sudo chown -R tutor-a:tutor-a /home/tutor-a/.ssh

repo_url="http://github.com/Beellzebub/page"
project_src="/home/ubuntu/project_src"

git clone "$repo_url" "$project_src"
sudo mkdir /var/www/tutorial
sudo cp "$project_src/html/index.html" "/var/www/tutorial/"
sudo cp "$project_src/nginx/new_config" "/etc/nginx/sites-enabled/"
sudo systemctl restart nginx
