#!/bin/bash

aws iam create-role \
--role-name  CloudEngJ2Ch05Role \
--description "Provides read only access to all EC2 instances and S3 buckets" \
--assume-role-policy-document file://./json/ec2-role-trust-policy.json

aws iam attach-role-policy \
--role-name CloudEngJ2Ch05Role \
--policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess

aws iam attach-role-policy \
--role-name CloudEngJ2Ch05Role \
--policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws iam create-instance-profile \
--instance-profile-name CloudEngJ2Ch05Profile

aws iam add-role-to-instance-profile \
--instance-profile-name CloudEngJ2Ch05Profile \
--role-name  CloudEngJ2Ch05Role