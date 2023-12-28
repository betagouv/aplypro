# frozen_string_literal: true

class FetchStudentsJob < ApplicationJob
  queue_as :default

  retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 10

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(fetching_students: true)

    block.call

    establishment.update!(fetching_students: false)
  end

  def perform(establishment)
    StudentApi.fetch_students!(establishment.students_provider, establishment.uai)
  end
end
