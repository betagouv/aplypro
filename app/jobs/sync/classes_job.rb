# frozen_string_literal: true

module Sync
  class ClassesJob < ApplicationJob
    include FregataProof

    queue_as :default

    discard_on ActiveJob::DeserializationError, Faraday::ResourceNotFound,
               Student::Mappers::Errors::SchoolingParsingError

    around_perform do |job, block|
      establishment = job.arguments.first

      establishment.update!(fetching_students: true)

      block.call

      establishment.update!(fetching_students: false)
    end

    def perform(establishment, school_year)
      return true if establishment.students_provider == "csv"

      api = establishment.students_api
      data = api.fetch_resource(:establishment_students, uai: establishment.uai, start_year: school_year.start_year)

      return if data.nil?

      api.mapper.new(data, establishment.uai).parse!
    end
  end
end
