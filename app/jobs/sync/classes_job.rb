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
      # NOTE: there is a bug in Sygne where students are removed from classes
      # earlier than they should be so we disable student list fetching for now
      # (only in production because we want to keep our tests intact)
      return true if establishment.provided_by?(:sygne) && Rails.env.production?

      api = establishment.students_api

      api
        .fetch_resource(:establishment_students, uai: establishment.uai, school_year: school_year.start_year)
        .then { |data| api.mapper.new(data, establishment.uai).parse! }
    end
  end
end
