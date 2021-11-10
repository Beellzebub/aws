#!/bin/bash

function aws_cli_install {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -r aws
  rm awscliv2.zip
}

function run_user_data {
  user_data="$1"
  bucket_date_and_name=$(aws s3 ls)
  bucket_name=$(echo "$bucket_date_and_name" | cut -d" " -f3)
  aws s3 cp "s3://$bucket_name/user-data/$user_data" ./
  chmod +x "./$user_data"
  sudo "./$user_data"
}

. /etc/os-release

if [[ $ID == "ubuntu" ]] ; then
  sudo apt-get update -y
  sudo apt-get install unzip -y
  aws_cli_install
  run_user_data "config_ubuntu.sh"
elif [[ $ID == "amzn" ]] ; then
  sudo yum update -y
  aws_cli_install
  run_user_data "config_amazon_linux.sh"
fi