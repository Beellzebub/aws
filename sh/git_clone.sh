#!/bin/bash

repo_url="http://github.com/Beellzebub/multi_tierApp"

function git_clone {
    git clone "$1"
}

git_clone $repo_url