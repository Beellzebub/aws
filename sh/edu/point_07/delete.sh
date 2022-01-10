#!/bin/bash

# Terminate instance with tag = "cec"

tag_name="cec"

instance_list=$(aws ec2 describe-instances \
--filters "Name=tag-value,Values=$tag_name" "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

for instance_id in $instance_list ; do
  aws ec2 terminate-instances --instance-ids "$instance_id"
  echo "Terminate instance: $instance_id"
done