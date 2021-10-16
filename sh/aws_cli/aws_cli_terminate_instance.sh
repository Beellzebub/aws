#!/bin/bash

# Terminate instance:

instance_name="ubuntu-ud1"

instance_id=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$instance_name" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

aws ec2 terminate-instances --instance-ids "$instance_id"