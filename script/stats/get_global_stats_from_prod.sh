production_name=$1
bash ./execute_in_prod.sh $production_name "puts Stats::Main.new.global_data_csv" global_stats.csv
bash ./execute_in_prod.sh $production_name "puts Stats::Main.new.bops_data_csv" bops_stats.csv
bash ./execute_in_prod.sh $production_name "puts Stats::Main.new.menj_academies_data_csv" menj_academies_stats.csv
bash ./execute_in_prod.sh $production_name "puts Stats::Main.new.establishments_data_csv" establishments_stats.csv