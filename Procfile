web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v
workerdoc: bundle exec sidekiq --queue documents
payments: bundle exec sidekiq --queue payments
postdeploy: bundle exec rails db:prepare
