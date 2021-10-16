#!/bin/bash

aws iam create-role \
--role-name  EC2toS3FullAccess \
--description "Allow EC2 to do everything with any S3 buckets" \
--assume-role-policy-document file://./json/ec2-role-trust-policy.json

aws iam put-role-policy \
--role-name  EC2toS3FullAccess \
--policy-name S3-Permissions \
--policy-document file://./json/ec2-role-access-policy.json

aws iam create-instance-profile \
--instance-profile-name EC2toS3FullAccessProfile

aws iam add-role-to-instance-profile \
--instance-profile-name EC2toS3FullAccessProfile \
--role-name  EC2toS3FullAccess
