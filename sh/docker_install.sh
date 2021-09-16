#!/bin/bash

docker_pkg="docker-ce"
compose_pkg="docker-compose"
key_url="https://download.docker.com/linux/ubuntu/gpg"
repo_url="https://download.docker.com/linux/ubuntu"


function docker_install {
  if ! dpkg -s "$1" &> /dev/null ; then
    echo "$1 not installed."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL "$2" | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] $3 $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli
    echo "install $1 done."
  else
    echo "$1 installed."
  fi
}

function compose_install {
  sudo apt-get install "$1"
}

docker_install $docker_pkg $key_url $repo_url
compose_install $compose_pkg
