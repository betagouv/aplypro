# frozen_string_literal: true

module ASP
  class PaymentRequestTransition < ApplicationRecord
    include Statesman::Adapters::ActiveRecordTransition

    belongs_to :asp_payment_request, class_name: "ASP::PaymentRequest", inverse_of: :asp_payment_request_transitions

    after_destroy :update_most_recent, if: :most_recent?

    private

    def update_most_recent
      last_transition = asp_payment_request.asp_payment_request_transitions.order(:sort_key).last

      return if last_transition.blank?

      last_transition.update_column(:most_recent, true) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
