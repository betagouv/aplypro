# frozen_string_literal: true

module FregataProof
  extend ActiveSupport::Concern

  # NOTE: Fregata has a nasty tendency to respond 401 on endpoints
  # and yields only after ~6/8 attempts, this makes sure we retry jobs that need it
  included do
    sidekiq_options retry: false
    retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 10
    discard_on Faraday::ServerError # 504 sometimes
  end
end
