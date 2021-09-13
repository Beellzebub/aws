#!/bin/bash

pkg_name="docker-ce"

function docker_install {
  if ! dpkg -s "$1" &> /dev/null ; then
    echo "$1 not installed."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    echo "install $1 done."
  else
    echo "$1 installed."
  fi
}

docker_install $pkg_name

