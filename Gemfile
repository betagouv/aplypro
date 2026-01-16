# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use PostgreSQL as the database for Active Record
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# saves the DSFR boilerplate
gem "dsfr-view-components"

# nicer templates
gem "haml-rails"

# ribs validation
gem "bank-contact"

# document generation
gem "hexapdf", require: false

# document storage
gem "aws-sdk-s3", require: false

# user auth
gem "devise"
gem "devise-i18n"
gem "omniauth-oauth2"
gem "omniauth_openid_connect", require: false

# data fetching
gem "faraday"

# pagination
gem "kaminari"

# state management
gem "statesman"

# proudly found elsewhere - breadcrumbs
gem "breadcrumbs_on_rails"

# error reporting
gem "sentry-rails"
gem "sentry-ruby"

# TODO: remove when following bug is fixed -> https://stackoverflow.com/questions/79844786/ruby-on-rails-redis-connection-pool-wrong-number-of-arguments-given-1-expected
gem "connection_pool", "< 3"
gem "sidekiq", "8.0.10"

gem "active_decorator"

gem "redis"
# gem "sidekiq"

gem "rack-attack"

gem "dry-schema"
gem "dry-transformer"

gem "zipline", git: "https://github.com/alhajrahmoun/zipline.git", branch: "support-rails-8.0"

gem "csv"

# payments: XML mapping
gem "nokogiri"

# payments: XML exchange
gem "net-sftp"

# stats
gem "chartkick"
gem "groupdate"
gem "scenic"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "wdm", ">= 0.1.0", platforms: %i[mingw mswin x64_mingw jruby]
end

group :test do
  gem "capybara"
  gem "cucumber-rails", require: false
  gem "database_cleaner-active_record"
  gem "faker", require: false
  gem "guard"
  gem "guard-cucumber"
  gem "guard-rspec"
  gem "rails-controller-testing"
  gem "rspec"
  gem "rspec-collection_matchers"
  gem "rubocop"
  gem "rubocop-capybara"
  gem "rubocop-factory_bot"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "rubocop-rspec_rails"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"
  gem "spring-commands-cucumber"
  gem "spring-commands-rspec"
  gem "spring-commands-rubocop"
  gem "spring-watcher-listen"

  gem "brakeman"
  gem "whenever", require: false
end
