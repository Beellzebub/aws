#!/bin/bash

aws iam remove-role-from-instance-profile --instance-profile-name EC2toS3FullAccessProfile --role-name EC2toS3FullAccess

attach_polisy=$(aws iam list-attached-role-policies --role-name EC2toS3FullAccess --query "AttachedPolicies[].PolicyArn | [0]" --output text)

aws iam detach-role-policy --role-name EC2toS3FullAccess --policy-arn "$attach_polisy"

aws iam delete-instance-profile --instance-profile-name EC2toS3FullAccessProfile

aws iam delete-role --role-name EC2toS3FullAccess