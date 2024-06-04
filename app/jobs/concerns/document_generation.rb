# frozen_string_literal: true

module DocumentGeneration
  extend ActiveSupport::Concern

  included do
    queue_as :documents
    sidekiq_options retry: false
    retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 10
  end

  module ClassMethods
    def after_discard_callback(job, attribute)
      schooling = job.arguments.first
      schooling.update!(attribute => false)
    end

    def around_perform_callback(job, attribute, &block)
      schooling = job.arguments.first
      schooling.update!(attribute => true)

      block.call

      schooling.update!(attribute => false)
    end
  end
end
