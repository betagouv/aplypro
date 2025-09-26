# frozen_string_literal: true

module Sync
  class AllClassesJob < ApplicationJob
    queue_as :default

    def perform
      school_year = SchoolYear.current

      Establishment.find_each do |establishment|
        Sync::ClassesJob.perform_later(establishment, school_year)
      end
    end
  end
end
