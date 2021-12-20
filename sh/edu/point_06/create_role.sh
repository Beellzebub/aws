#!/bin/bash

aws iam create-role \
--role-name  CloudEngJ2Ch06Role \
--description "Allows read only access to all EC2 instances and S3 buckets, assume Update DNS Zone role in 327742888260" \
--assume-role-policy-document file://./json/ec2-role-trust-policy.json

aws iam attach-role-policy \
--role-name CloudEngJ2Ch06Role \
--policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess

aws iam attach-role-policy \
--role-name CloudEngJ2Ch06Role \
--policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws iam attach-role-policy \
--role-name CloudEngJ2Ch06Role \
--policy-arn arn:aws:iam::327742888260:policy/CloudEngJ2Ch06CrossAccount