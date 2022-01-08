#!/bin/bash

# $1-region
function vpc {
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
function subnet {
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
function security {
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
function key {
  select_key="$(aws ec2 describe-key-pairs \
	--filters "Name=key-name, Values=$2" \
	--query "KeyPairs[].KeyName" \
	--region "$1" \
	--output text)"

	if [[ -z "$select_key" ]]; then
	  echo "Key $2 created."
	else
		echo "Key $2 exists."
  fi
}

arr="$(cat regions-allowed.conf)"

for region in $arr; do
  echo "-------------------------"
  echo "Region: $region"
  vpc "$region"
  subnet "$region"
  security "$region" public-ssh-and-http "22 80"
  security "$region" public-ssh-http-81 "22 80 81"
  key "$region" student-ed25519 ed25519
  key "$region" student-rsa rsa
done