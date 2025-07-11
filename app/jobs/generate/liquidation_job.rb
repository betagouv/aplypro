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
      broadcast_completion(schooling)
    end

    private

    def generate_document(schooling)
      schooling.increment(:liquidation_version)
      io = Generator::Liquidation.new(schooling).write
      ASP::AttachDocument.from_schooling(io, schooling, :liquidation)
    end

    def sync_data(schooling)
      Sync::StudentJob.new.perform(schooling)
    end

    def broadcast_completion(schooling)
      schooling.reload
      Turbo::StreamsChannel.broadcast_render_to(
        "liquidation_#{schooling.id}",
        partial: "asp/schoolings/liquidation_complete",
        locals: { schooling: schooling }
      )
    end
  end
end
