# frozen_string_literal: true

module Generate
  class LiquidationJob < ApplicationJob
    include DocumentGeneration

    def perform(schooling)
      return unless schooling.pfmps.any?

      sync_data(schooling)

      Schooling.transaction do
        generate_document(schooling)
        schooling.save!
      end
    end

    private

    def generate_document(schooling)
      schooling.increment(:liquidation_version)
      io = Generator::Pfmp::Liquidation.new(schooling).write
      ASP::AttachDocument.from_schooling(io, schooling, :liquidation)
    end

    def sync_data(schooling)
      Sync::StudentJob.new.perform(schooling)
    end
  end
end
