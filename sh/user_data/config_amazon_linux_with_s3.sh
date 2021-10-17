#!/bin/bash

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip
sudo ./aws/install

rm -r aws
rm awscliv2.zip

bucket_date_and_name=$(aws s3 ls)
bucket_name=$(echo "$bucket_date_and_name" | sed -r 's/[0-9]+-[0-9]+-[0-9]+ [0-9]+:[0-9]+:[0-9]+ //')

aws s3 cp "s3://$bucket_name/user-data/config_amazon_linux.sh" ./

chmod +x config_amazon_linux.sh
sudo ./config_amazon_linux.sh