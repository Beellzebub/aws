#!/bin/bash

apt-get update -y
apt-get install nginx -y
apt-get install fail2ban -y
apt-get install git -y
apt-get install jq -y

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
public_ipv4="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"

instance_name="$(aws ec2 describe-instances \
--instance-ids "$instance_ids" \
--query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
--output text \
--region eu-central-1)"

account_id=$(aws sts get-caller-identity --query Account --output text)

hostnamectl set-hostname "$instance_name.$account_id.cirruscloud.click"

aws sts assume-role \
--role-arn "arn:aws:iam::272304640086:role/CloudEngJ2Ch06UpdateDNSZone327742888260" \
--role-session-name "Route53" \
--query "Credentials" \
--output json > ./temp.json

access_key="$(jq -r '.AccessKeyId' < ./temp.json)"
secret_access_key="$(jq -r '.SecretAccessKey' < ./temp.json)"
session_token="$(jq -r '.SessionToken' < ./temp.json)"

export AWS_ACCESS_KEY_ID="$access_key"
export AWS_SECRET_ACCESS_KEY="$secret_access_key"
export AWS_SESSION_TOKEN="$session_token"

rm ./temp.json

zone_id="$(aws route53 list-hosted-zones \
--query "HostedZones[?Name=='$account_id.cirruscloud.click.'].Id" \
--output text)"

cat >> ./temp.json << EOF
{
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "$account_id.cirruscloud.click.",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{ "Value": "$public_ipv4"}]
            }
        }]
}
EOF

aws route53 change-resource-record-sets \
--hosted-zone "$zone_id" \
--change-batch file://./temp.json

rm ./temp.json