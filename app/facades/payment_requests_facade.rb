# frozen_string_literal: true

class PaymentRequestsFacade
  attr_accessor :payment_requests

  def initialize(payment_requests)
    @payment_requests = payment_requests
  end

  def payment_requests_counts
    @payment_requests_counts ||= ASP::PaymentRequest::STATES_GROUPS_FOR_COUNTS.to_h do |states|
      count = states.map { |state| payment_requests_all_status_counts[state] }.compact.sum
      [states.first, count]
    end
  end

  private

  def payment_requests_all_status_counts
    @payment_requests_all_status_counts ||=
      payment_requests
      .joins(ASP::PaymentRequest.most_recent_transition_join)
      .group(:to_state)
      .count
      .transform_keys { |state| state.nil? ? initial_state : state.to_sym }
  end

  def initial_state
    ASP::PaymentRequestStateMachine.initial_state.to_sym
  end
end
