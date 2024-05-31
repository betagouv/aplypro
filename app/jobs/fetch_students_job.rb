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
    api = establishment.students_api

    api
      .fetch_resource(:establishment_students, uai: establishment.uai)
      .then { |data| api.mapper.new(data, establishment.uai).parse! }
  end
end
