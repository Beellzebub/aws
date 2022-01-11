#!/bin/bash

# Terminate instance with tag = "cec"
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

# Terminate running instances:
for region in $list_of_region; do
  instance_list=$(aws ec2 describe-instances \
  --filters "Name=tag-value,Values=$tag_name" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --region "$region" \
  --output text)

  for instance_id in $instance_list ; do
    aws ec2 terminate-instances --instance-ids "$instance_id" --region "$region"
    echo "Terminate instance: $instance_id"
  done
done