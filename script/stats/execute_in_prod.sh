
production_name=$1
ruby_string=$2
output_file_path=$3

# We have 2 levels of interpolation before reaching the rails runner, so we need 2 "\" in front of the quotes
escaped_ruby_string=$(echo $ruby_string | sed "s/\"/\\\\\"/g")

echo "Executing '$2' in production. Will store the output in '$output_file_path'"

scalingo -region osc-secnum-fr1 --app $production_name run rails runner \""$escaped_ruby_string"\" | sed "1d" > $output_file_path

echo "Done."