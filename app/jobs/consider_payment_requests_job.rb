# frozen_string_literal: true

class ConsiderPaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform # rubocop:disable Metrics/AbcSize
    requests = ASP::PaymentRequest.to_consider

    correctable, normal = requests.partition do |r|
      r.pfmp.student.pfmps.any? do |pfmp|
        pfmp.transitions.any? { |transition| transition.to_state.eql?("rectified") }
      end
    end

    ActiveJob.perform_all_later(
      SendCorrectionAdresseJob.new(correctable.map { |r| r.pfmp.id }),
      normal.map { |r| PreparePaymentRequestJob.new(r) }
    )
  end
end
