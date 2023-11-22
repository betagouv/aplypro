web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v
workerdoc: bundle exec sidekiq --queue documents --concurrency 1
postdeploy: bundle exec rails db:prepare
