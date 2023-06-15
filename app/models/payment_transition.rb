# frozen_string_literal: true

class PaymentTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :payment

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = payment.payment_transitions.order(:sort_key).last
    return if last_transition.blank?

    last_transition.update_column(:most_recent, true) # rubocop:disable Rails/SkipsModelValidations
  end
end
