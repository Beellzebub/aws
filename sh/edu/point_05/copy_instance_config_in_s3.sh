#!/bin/bash

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="cec-$account_id-j2"

aws s3 cp ./instance_config/config_ubuntu.sh "s3://$bucket_name/user-data/"
aws s3 cp ./instance_config/config_amazon_linux.sh "s3://$bucket_name/user-data/"