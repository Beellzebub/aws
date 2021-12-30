#!/bin/bash

arr="$(cat regions-allowed.conf)"

IFS=$'\n'
for region in $arr; do
echo "$region"
is_default_VPC="$(aws ec2 describe-vpcs --query "Vpcs[].IsDefault" --output text --region "$region")"
echo "$is_default_VPC"
done