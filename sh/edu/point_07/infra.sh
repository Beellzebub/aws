#!/bin/bash

arr="$(cat regions-allowed.conf)"

for region in $arr; do
  echo "$region"

  status_of_default_VPC="$(aws ec2 describe-vpcs \
  --filters "Name=isDefault, Values=true" \
  --query "Vpcs[*].IsDefault" \
  --output text \
  --region "$region")"

  if [[ -z "$status_of_default_VPC" ]]; then
    echo "False"
  else
    echo "True"
  fi

done