#!/bin/bash

# Config:

security_group="public-ssh-http-81"
key_pair="student-ed25519"
user_data="config_ubuntu.sh"
instance_name="ubuntu-ud1"
os_release="ubuntu" # ubuntu or amzn

if [[ $os_release == "ubuntu" ]] ; then
  ami="ami-058e6df85cfc7760b"
elif [[ $os_release == "amzn" ]] ; then
  ami="ami-05f7491af5eef733a"
fi

# Start instance:

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

aws ec2 run-instances \
--image-id "$ami" \
--count 1 \
--instance-type t2.micro \
--key-name "$key_pair" \
--security-group-ids "$sg_id" \
--subnet-id "$subnet_id" \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
--user-data "file://./$user_data"
