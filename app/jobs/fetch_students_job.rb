# frozen_string_literal: true

class FetchStudentsJob < ApplicationJob
  include FregataProof

  queue_as :default

  discard_on ActiveJob::DeserializationError, Faraday::ResourceNotFound, Student::Mappers::Errors::SchoolingParsingError

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(fetching_students: true)

    block.call

    establishment.update!(fetching_students: false)
  end

  def perform(establishment)
    # NOTE: there is a bug in Sygne where students are removed from classes
    # earlier than they should be so we disable student list fetching for now
    return true if establishment.students_provider == "sygne" && Rails.env.production?

    api = establishment.students_api

    api
      .fetch_resource(:establishment_students, uai: establishment.uai)
      .then { |data| api.mapper.new(data, establishment.uai).parse! }
  end
end
