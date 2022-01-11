#!/bin/bash

# List of running instances with tag = "cec"
tag_name="cec"

# Validation of regions-allowed.conf:
if [[ -e regions-allowed.conf ]]; then
  list_of_region="$(cat regions-allowed.conf)"
  if [[ -z "$list_of_region" ]]; then
    echo "File regions-allowed.conf don't contain regions."
    exit
  fi
else
  echo "File regions-allowed.conf not found."
  exit
fi

# Print list of running instances:
for region in $list_of_region; do
  instance_id="Instance:InstanceId"
  public_ip="PublicIP:PublicIpAddress"
  os="OS:Tags[?Key=='Platform']|[0].Value"
  availability_zone="Zone: Placement.AvailabilityZone"
  aws ec2 describe-instances \
  --filters "Name=tag-value,Values=$tag_name" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].{$instance_id, $public_ip, $os, $availability_zone}" \
  --region "$region" \
  --output table
done