#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install epel -y
sudo yum install nginx -y
sudo yum install fail2ban -y
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

#sshd config for amzn
sed -i "s/$(grep -m 1 "PermitRootLogin" /etc/ssh/sshd_config)/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/$(grep -m 1 "PasswordAuthentication" /etc/ssh/sshd_config)/PasswordAuthentication no/" /etc/ssh/sshd_config
sudo systemctl restart sshd

#sudoers config for amzn
sudo sed -i "s/$(sudo grep "# %wheel" /etc/sudoers)/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sudo sed -i "s/$(sudo grep -m 1 "%wheel" /etc/sudoers)/# %wheel ALL=(ALL) ALL/" /etc/sudoers

sudo adduser tutor-a
sudo usermod -aG wheel tutor-a
sudo mkdir /home/tutor-a/.ssh
sudo touch /home/tutor-a/.ssh/authorized_keys
sudo echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" >> /home/tutor-a/.ssh/authorized_keys
sudo chmod 700 /home/tutor-a/.ssh
sudo chmod 600 /home/tutor-a/.ssh/authorized_keys
sudo chown -R tutor-a:tutor-a /home/tutor-a/.ssh
