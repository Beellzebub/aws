#!/bin/bash

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="cec-$account_id-j2"

aws s3 mb "s3://$bucket_name" --region eu-central-1