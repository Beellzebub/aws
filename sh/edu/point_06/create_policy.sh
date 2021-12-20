#!/bin/bash

aws iam create-policy \
--policy-name  CloudEngJ2Ch06CrossAccount \
--description "Cross account policy." \
--policy-document file://./json/route53-cross-policy.json