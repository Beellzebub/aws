#!/bin/bash

# $1-region
function check_create_vpc {
  status_of_default_VPC="$(aws ec2 describe-vpcs \
  --filters "Name=isDefault, Values=true" \
  --query "Vpcs[].IsDefault" \
  --output text \
  --region "$1")"

  if [[ -z "$status_of_default_VPC" ]]; then
    aws ec2 create-default-vpc --region "$1"
    echo "Default VPC created."
  else
    echo "Default VPC exists."
  fi
}

# $1-region
function check_create_subnet {
  availability_zones="$(aws ec2 describe-availability-zones \
  --query "AvailabilityZones[].ZoneName" \
  --output text \
  --region "$1")"

  subnets="$(aws ec2 describe-subnets \
  --filters "Name=defaultForAz, Values=true" \
  --query "Subnets[].AvailabilityZone" \
  --output text \
  --region "$1")"

  for zone in $availability_zones; do
    default_subnet="False"
    for subnet in $subnets; do
      if [[ "$zone" == "$subnet" ]]; then
        default_subnet="True"
      fi
    done
    if [[ "$default_subnet" == "True" ]]; then
      echo "Default subnet in $zone zone exists."
    else
      default_subnet="False"
      aws ec2 create-default-subnet --availability-zone "$zone" --region "$1"
      echo "Default subnet in $zone zone created."
    fi
  done
}

# $1-region $2-group name $3-list of ports
function check_create_security_group {
	select_group="$(aws ec2 describe-security-groups \
	--filters "Name=group-name, Values=$2" \
	--query "SecurityGroups[].GroupName" \
	--region "$1" \
	--output text)"

	if [[ -z "$select_group" ]]; then
	  group_id="$(aws ec2 create-security-group \
	  --description "$2" \
	  --group-name "$2" \
	  --query "GroupId" \
	  --region "$1" \
	  --output text)"
	  echo "Group $2 created."
    for port in $3; do
      aws ec2 authorize-security-group-ingress \
      --group-id "$group_id" \
      --protocol "tcp" \
      --port "$port" \
      --cidr 0.0.0.0/0 \
      --region "$1"
    done
	else
		echo "Group $2 exists."
  fi
}

# $1-region $2-key name $3-key type
function check_copy_secret_key {
  select_key="$(aws ec2 describe-key-pairs \
	--filters "Name=key-name, Values=$2" \
	--query "KeyPairs[].KeyName" \
	--region "$1" \
	--output text)"

	if [[ -z "$select_key" ]]; then
	  file_with_keys="$HOME/.ssh/id_student_$3"
	  if [[ -e "$file_with_keys" ]]; then
      aws ec2 import-key-pair \
      --key-name "$2" \
      --region "$1" \
      --public-key-material fileb://"$file_with_keys"
      echo "Key $2 copied successfully."
	  else
	    echo  "File $file_with_keys not found."
	  fi
	else
		echo "Key $2 exists."
  fi
}

arr="$(cat regions-allowed.conf)"

for region in $arr; do
  echo "-------------------------"
  echo "Region: $region"
  check_create_vpc "$region"
  check_create_subnet "$region"
  check_create_security_group "$region" public-ssh-and-http "22 80"
  check_create_security_group "$region" public-ssh-http-81 "22 80 81"
  check_copy_secret_key "$region" student-ed25519 ed25519
  check_copy_secret_key "$region" student-rsa rsa
done