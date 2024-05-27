#!/bin/bash

region_name=$1
production_name=$2
ruby_string=$3
output_file_path=$4

# We have 2 levels of interpolation before reaching the rails runner, so we need 2 "\" in front of the quotes
escaped_ruby_string=$(echo $ruby_string | sed "s/\"/\\\\\"/g")

echo "Executing '$2' in production. Will store the output in '$output_file_path'"

scalingo --region $region_name --app $production_name run rails runner \""$escaped_ruby_string"\" | sed "1d" > $output_file_path

if [ $? -ne 0 ]; then
  echo "Error: Scalingo command failed. Stopping execution."
  exit 1
fi

echo "Done."
