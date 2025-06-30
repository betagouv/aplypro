# frozen_string_literal: true

module Generate
  class LiquidationJob < ApplicationJob
    include DocumentGeneration

    def perform(pfmp)
      sync_data(pfmp)

      Pfmp.transaction do
        generate_document(pfmp)
        schooling.save!
      end
    end

    private

    def generate_document(pfmp)
      pfmp.increment(:liquidation_version)
      io = Generator::Liquidation.new(pfmp).write
      ASP::AttachDocument.from_pfmp(io, pfmp)
    end

    def sync_data(pfmp)
      Sync::StudentJob.new.perform(pfmp)
    end
  end
end
