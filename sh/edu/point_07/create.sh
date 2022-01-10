#!/bin/bash

# Infrastructure parameters:
security_group="public-ssh-http-81"
key_pair="student-ed25519"
instance_profile="CloudEngJ2Ch06Profile"
version=7

# Argument handling:
while [ -n "$1" ]; do
  case "$1" in
    --region) shift; echo "Selected region: $1"; arg_region="$1";;
    --version) shift; echo "Selected version: $1"; version="$1";;
    --os) shift; echo "Selected OS: $1"; arg_os="$1";;
    *) echo "Unknown argument: $1";;
  esac
  shift
done

# Argument validation:
if [[ -z "$arg_region" || -z "$arg_os" ]]; then
  echo "Provide arguments --region and --os."
	exit
fi

if [[ -e regions-allowed.conf ]]; then
  list_of_region="$(cat regions-allowed.conf)"
  if [[ -z "$list_of_region" ]]; then
    echo "File regions-allowed.conf don't contain regions."
    exit
  elif [[ -z $(grep "$arg_region" <<< "${list_of_region[*]}") ]]; then
    echo "Region $arg_region don't supported."
    exit
  fi
else
  echo "File regions-allowed.conf not found."
  exit
fi

# Infrastructure info:
sg_id=$(aws ec2 describe-security-groups \
--group-names "$security_group" \
--query 'SecurityGroups[*].GroupId' \
--region "$arg_region" \
--output text)
echo "Security group ID: $sg_id"

vpc_id=$(aws ec2 describe-vpcs \
--filters "Name=isDefault, Values=true" \
--query "Vpcs[*].VpcId" \
--region "$arg_region" \
--output text)
echo "VPC ID: $vpc_id"

subnet_id=$(aws ec2 describe-subnets \
--filters "Name=vpc-id,Values=$vpc_id" \
--query "Subnets[0].SubnetId" \
--region "$arg_region" \
--output text)
echo "Subnet ID: $subnet_id"


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
  --region "$arg_region" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$2}, {Key=Type,Value=cec}, {Key=Platform, Value=$3}]" \
  --user-data "file://./user_data.sh"
} > /dev/null

# Run instance:
if [[ "$arg_os" == "al2" ]]; then
  amazon_ami="$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --region "$arg_region" \
  --query "Parameters[].Value" \
  --output text)"
  echo "Amazon Linux AMI: $amazon_ami"
  run_instance "$amazon_ami" "al2-ud$version" "Amazon Linux"
  echo "Instance run: al2-ud$version"
elif [[ "$arg_os" == "ubuntu" ]]; then
  ubuntu_ami="$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id \
  --region "$arg_region" \
  --query "Parameters[].Value" \
  --output text)"
  echo "Ubuntu AMI: $ubuntu_ami"
  run_instance "$ubuntu_ami" "ubuntu-ud$version" "Ubuntu"
  echo "Instance run: ubuntu-ud$version"
else
  echo "Unknown operating system."
fi






