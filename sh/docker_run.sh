#!/bin/bash

project_src="$HOME/project_src"
project_dir="$HOME/web_project"

mkdir "$project_dir"
sudo docker build -t web_im "$project_src/application"
sudo docker run -it --rm --name web_cont -p 5000:5000 web_im