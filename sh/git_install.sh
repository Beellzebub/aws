#!/bin/bash

git_pkg="git"

function git_install {
  if ! dpkg -s "$1" &> /dev/null ; then
    echo "$1 not installed."
    sudo apt-get update
    if sudo apt-get install -y "$1" ; then
      echo "install $1 done."
    fi
  else
    echo "$1 installed."
  fi
}

git_install $git_pkg

