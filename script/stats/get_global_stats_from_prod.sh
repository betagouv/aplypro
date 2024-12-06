#!/bin/bash

region_name="$1"
production_name="$2"
start_year="$3"

# infer script dir to be able to run the script from out of the stats folder too
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

bash "$script_dir/execute_in_prod.sh" "$region_name" "$production_name" "puts Stats::Main.new($start_year).global_data_csv" "$script_dir/global_stats.csv"
bash "$script_dir/execute_in_prod.sh" "$region_name" "$production_name" "puts Stats::Main.new($start_year).bops_data_csv" "$script_dir/bops_stats.csv"
bash "$script_dir/execute_in_prod.sh" "$region_name" "$production_name" "puts Stats::Main.new($start_year).menj_academies_data_csv" "$script_dir/menj_academies_stats.csv"
bash "$script_dir/execute_in_prod.sh" "$region_name" "$production_name" "puts Stats::Main.new($start_year).establishments_data_csv" "$script_dir/establishments_stats.csv"
