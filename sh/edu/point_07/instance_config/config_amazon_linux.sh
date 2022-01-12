#!/bin/bash

yum update -y
amazon-linux-extras install epel -y
yum install nginx -y
yum install fail2ban -y
yum install git -y
yum install jq -y

systemctl enable nginx
systemctl start nginx
systemctl enable fail2ban
systemctl start fail2ban
systemctl enable firewalld
systemctl start firewalld

cat >> /etc/firewalld/services/nginx.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
<short>nginx</short>
<description>nginx with non-standard port</description>
<port protocol="tcp" port="80"/>
<port protocol="tcp" port="81"/>
</service>
EOF

firewall-cmd --reload
firewall-cmd --zone=public --add-service=nginx --permanent
firewall-cmd --reload

#sshd config for amzn
sed -i "s/$(grep -m 1 "PermitRootLogin" /etc/ssh/sshd_config)/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/$(grep -m 1 "PasswordAuthentication" /etc/ssh/sshd_config)/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart sshd

#sudoers config for amzn
sed -i "s/$(grep "# %wheel" /etc/sudoers)/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -i "s/$(grep -m 1 "%wheel" /etc/sudoers)/# %wheel ALL=(ALL) ALL/" /etc/sudoers

adduser tutor-a
usermod -aG wheel tutor-a
mkdir /home/tutor-a/.ssh
touch /home/tutor-a/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChvBKAJbIt0H0O26DbZnu2I0kHG+OJBEvR0UkgqWwFb tutor-a" >> /home/tutor-a/.ssh/authorized_keys
chmod 700 /home/tutor-a/.ssh
chmod 600 /home/tutor-a/.ssh/authorized_keys
chown -R tutor-a:tutor-a /home/tutor-a/.ssh

repo_url="http://github.com/Beellzebub/page"
project_src="/home/ec2-user/project_src"

git clone "$repo_url" "$project_src"
mkdir -p /var/www/tutorial
cp "$project_src/html/index.html" "/var/www/tutorial/"
cp "$project_src/nginx/new_config" "/etc/nginx/conf.d/new.conf"
systemctl restart nginx

instance_ids="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
region="$(curl http://169.254.169.254/latest/meta-data/placement/region)"

instance_name="$(aws ec2 describe-instances \
--instance-ids "$instance_ids" \
--query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
--region "$region" \
--output text)"

account_id=$(aws sts get-caller-identity --query Account --output text)

DNS_zone="$account_id.cirruscloud.click."
DNS="$instance_name.$DNS_zone"

hostnamectl set-hostname "$DNS"

bucket_date_and_name=$(aws s3 ls)
bucket_name=$(echo "$bucket_date_and_name" | cut -d" " -f3)
aws s3 cp "s3://$bucket_name/services/service_route53.sh" /usr/local/bin/service_route53.sh
chmod +x /usr/local/bin/service_route53.sh

cat >> /etc/systemd/system/route53.service << EOF
[Unit]
Description=Route53 Dynamic DNS Update Service
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
TimeoutStartSec=30
ExecStart=/usr/local/bin/service_route53.sh
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl enable route53.service
systemctl start route53.service