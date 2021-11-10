#!/bin/bash

account_id=$(aws sts get-caller-identity --query Account --output text)
bucket_name="cec-$account_id-j2"

aws s3api put-bucket-versioning \
--bucket "$bucket_name" \
--versioning-configuration Status=Enabled
