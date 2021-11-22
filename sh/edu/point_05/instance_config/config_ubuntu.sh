#!/bin/bash

apt-get update -y
apt-get install nginx -y
apt-get install fail2ban -y
apt-get install git -y

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

instance_ids="$(curl http://169.254.169.254/latest/meta-data/instance-id)"

instance_name="$(aws ec2 describe-instances \
--instance-ids "$instance_ids" \
--query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
--output text)"

hostnamectl set-hostname "$instance_name.ubuntu-instance.ddns.net"

cat >> /etc/no-ip2.conf << EOF
0.0.0.0�,L2JAxeth0dXNlcm5hbWU9ZW5pdW1pZyU0MGdtYWlsLmNvbSZwYXNzPUhwdyUzZm4lMmIlMjUlM2E3YyUyYylBdiEmaFtdPXVidW50dS1pbnN0YW5jZS5kZG5zLm5ldA==
EOF