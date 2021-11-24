#!/bin/bash

# List of running instances with tag = "cec"

tag_name="cec"

aws ec2 describe-instances \
--filters "Name=tag-value,Values=$tag_name" "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].{Instance:InstanceId, PublicIP:PublicIpAddress, OS:Tags[?Key=='Platform']|[0].Value}" \
--output table