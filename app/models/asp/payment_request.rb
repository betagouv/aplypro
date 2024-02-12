# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    belongs_to :asp_request, class_name: "ASP::Request"
    belongs_to :payment

    has_many :asp_payment_request_transitions,
             class_name: "ASP::PaymentRequestTransition",
             dependent: :destroy,
             inverse_of: :asp_payment_request

    include Statesman::Adapters::ActiveRecordQueries[
      transition_class: ASP::PaymentRequestTransition,
      initial_state: ASP::PaymentRequestStateMachine.initial_state,
    ]

    def state_machine
      @state_machine ||= ASP::PaymentRequestStateMachine.new(self, transition_class: ASP::PaymentRequestTransition)
    end

    delegate :can_transition_to?,
             :current_state, :history, :last_transition, :last_transition_to,
             :transition_to!, :transition_to, :in_state?, to: :state_machine

    def mark_as_sent!
      transition_to(:sent)
    end

    def reject!(attrs)
      transition_to!(:rejected, attrs)
    end
  end
end
