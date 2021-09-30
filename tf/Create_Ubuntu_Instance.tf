provider "aws" {
  region = var.aws-region
}

resource "aws_instance" "ubuntu-ud1" {
  count                  = 1
  ami                    = "ami-05f7491af5eef733a"
  instance_type          = "t3.micro"
  key-name               = var.aws-key-name
  vpc_security-group-ids = "sg-085c6e5baeb1a2886"
  subnet-id              = "subnet-0e205b907d94d99be"
  user_data              = <<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx -y
sudo apt-get install fail2ban -y
sudo apt-get install git

#sshd config for ubuntu
sed -i "s/$(grep -m 1 "PermitRootLogin" /etc/ssh/sshd_config)/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/$(grep -m 1 "PasswordAuthentication" /etc/ssh/sshd_config)/PasswordAuthentication no/" /etc/ssh/sshd_config
sudo systemctl restart sshd

#sudoers config for ubuntu
sudo sed -i "s/$(sudo grep "%sudo" /etc/sudoers)/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers

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
EOF
    tags = {
    Name = "ubuntu-ud1"
  }
}
