web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -v
workerdocuments: bundle exec sidekiq --queue documents
workerpayments: bundle exec sidekiq --queue payments,payments_serial
postdeploy: bundle exec rails db:prepare
