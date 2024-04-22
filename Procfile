web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v
worker-documents: bundle exec sidekiq --queue documents
worker-payments: bundle exec sidekiq --queue payments
postdeploy: bundle exec rails db:prepare
