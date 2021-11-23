#!/bin/bash

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="cec-$account_id-j2"

aws s3 cp ./noip_config/noip_ubuntu.conf "s3://$bucket_name/noip_config/"
aws s3 cp ./noip_config/noip_amazon_linux.conf "s3://$bucket_name/noip_config/"