#!/bin/bash

# Manual configuration:

# - function parameters
amzn_platform_name="Amazon Linux"
amzn_instance_name="al2-ud3"
ubuntu_platform_name="Ubuntu"
ubuntu_instance_name="ubuntu-ud3"

# - global parameters
security_group="public-ssh-http-81"
key_pair="student-ed25519"
instance_profile="EC2toS3FullAccessProfile"

# Auto configuration:

amzn_ami="$(aws ssm get-parameters \
--names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
--region eu-central-1 \
--query "Parameters[].Value" \
--output text)"
echo "Amazon Linux AMI: $amzn_ami"

ubuntu_ami="$(aws ssm get-parameters \
--names /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id \
--region eu-central-1 \
--query "Parameters[].Value" \
--output text)"
echo "Ubuntu AMI: $ubuntu_ami"

sg_id=$(aws ec2 describe-security-groups \
--group-names "$security_group" \
--query 'SecurityGroups[*].GroupId' \
--output text)
echo "Security group ID: $sg_id"

vpc_id=$(aws ec2 describe-vpcs \
--filters "Name=isDefault, Values=true" \
--query "Vpcs[*].VpcId" \
--output text)
echo "VPC ID: $vpc_id"

subnet_id=$(aws ec2 describe-subnets \
--filters "Name=vpc-id,Values=$vpc_id" \
--query "Subnets[0].SubnetId" \
--output text)
echo "Subnet ID: $subnet_id"

# Run instance:

# $1-ami, $2-instance_name, $3-platform tag
function run_instance {
  aws ec2 run-instances \
  --image-id "$1" \
  --count 1 \
  --instance-type t2.micro \
  --key-name "$key_pair" \
  --security-group-ids "$sg_id" \
  --subnet-id "$subnet_id" \
  --iam-instance-profile Name="$instance_profile" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$2}, {Key=Type,Value=cec}, {Key=Platform, Value=$3}]" \
  --user-data "file://./user_data.sh"
} > /dev/null

run_instance "$amzn_ami" "$amzn_instance_name" "$amzn_platform_name"
echo "Instance run: $amzn_instance_name"

run_instance "$ubuntu_ami" "$ubuntu_instance_name" "$ubuntu_platform_name"
echo "Instance run: $ubuntu_instance_name"