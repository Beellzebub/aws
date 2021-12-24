#!/bin/bash

public_ipv4="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"
instance_ids="$(curl http://169.254.169.254/latest/meta-data/instance-id)"

instance_name="$(aws ec2 describe-instances \
--instance-ids "$instance_ids" \
--query "Reservations[].Instances[].Tags[?Key=='Name'].Value" \
--output text \
--region eu-central-1)"

account_id=$(aws sts get-caller-identity --query Account --output text)

DNS_zone="$account_id.cirruscloud.click."
DNS="$instance_name.$DNS_zone"

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
--query "HostedZones[?Name=='$DNS_zone'].Id" \
--output text)"

cat >> ./temp.json << EOF
{
    "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
            "Name": "$DNS",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{ "Value": "$public_ipv4"}]
            }
        }]
}
EOF

aws route53 change-resource-record-sets \
--hosted-zone "$zone_id" \
--change-batch file://./temp.json > /dev/null

rm ./temp.json