#!/bin/bash

# Start instance:

sg_id=$(aws ec2 describe-security-groups \
--group-names public-ssh-http-81 \
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

aws ec2 run-instances \
--image-id ami-05f7491af5eef733a \
--count 1 \
--instance-type t3.micro \
--key-name student-ed25519 \
--security-group-ids "$sg_id" \
--subnet-id "$subnet_id" \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=ubuntu-cli}]" \
--user-data file:///path/config_Ubuntu.sh

# Stop instance:

instance_id=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=ubuntu-cli" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

aws ec2 stop-instances --instance-ids "$instance_id"