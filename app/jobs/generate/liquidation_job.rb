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
      io = Generator::Liquidation.new(pfmp).write
      attach_document(io, :liquidation)
    end

    def sync_data(pfmp)
      Sync::StudentJob.new.perform(pfmp)
    end
  end
end
