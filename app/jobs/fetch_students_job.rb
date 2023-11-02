# frozen_string_literal: true

class FetchStudentsJob < ApplicationJob
  queue_as :default

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(fetching_students: true)

    block.call

    establishment.update!(fetching_students: false)
  end

  def perform(establishment)
    StudentApi.fetch_students!(establishment)
  end
end
