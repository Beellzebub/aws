#!/bin/bash

repo_url="http://github.com/Beellzebub/multi_tierApp"
project_src="$HOME/project_src"

function git_clone {
    git clone "$1" "$2"
}

mkdir "$project_src"
git_clone $repo_url "$project_src"