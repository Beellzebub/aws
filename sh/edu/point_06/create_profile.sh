#!/bin/bash

aws iam create-instance-profile \
--instance-profile-name CloudEngJ2Ch06Profile

aws iam add-role-to-instance-profile \
--instance-profile-name CloudEngJ2Ch06Profile \
--role-name  CloudEngJ2Ch06Role