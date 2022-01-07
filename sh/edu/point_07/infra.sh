#!/bin/bash

# $1-region
function vpc {
  status_of_default_VPC="$(aws ec2 describe-vpcs \
  --filters "Name=isDefault, Values=true" \
  --query "Vpcs[*].IsDefault" \
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

arr="$(cat regions-allowed.conf)"

for region in $arr; do
  echo "-------------------------"
  echo "Region: $region"
  vpc "$region"
  subnet "$region"
done

