#!/bin/bash

aws iam remove-role-from-instance-profile --instance-profile-name EC2toS3FullAccessProfile --role-name EC2toS3FullAccess

put_polisy=$(aws iam list-role-policies --role-name EC2toS3FullAccess --query "PolicyNames | [0]" --output text)

aws iam delete-role-policy --role-name EC2toS3FullAccess --policy-name "$put_polisy"

aws iam delete-instance-profile --instance-profile-name EC2toS3FullAccessProfile

aws iam delete-role --role-name EC2toS3FullAccess