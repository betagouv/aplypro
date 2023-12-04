web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v -c 12
postdeploy: bundle exec rails db:prepare
