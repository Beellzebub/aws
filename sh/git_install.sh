#!/bin/bash

pkg_name="git"
repo_name="http://github.com/Beellzebub/multi_tierApp"

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

function git_clone {
    git clone "$1"
}

git_install $pkg_name
git_clone $repo_name
