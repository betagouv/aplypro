# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    belongs_to :asp_request, class_name: "ASP::Request", optional: true
    belongs_to :pfmp

    has_one :student, through: :pfmp
    has_one :schooling, through: :pfmp

    has_many :asp_payment_request_transitions,
             class_name: "ASP::PaymentRequestTransition",
             dependent: :destroy,
             inverse_of: :asp_payment_request

    validate :single_active_payment_request_per_pfmp, on: %i[create update]

    scope :active, -> { not_in_state(*ASP::PaymentRequestStateMachine::INACTIVE_STATES) }

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

    def mark_ready!
      transition_to!(:ready)
    end

    def mark_incomplete!
      transition_to!(:incomplete)
    end

    def mark_as_sent!
      transition_to!(:sent)
    end

    def reject!(attrs)
      transition_to!(:rejected, attrs)
    end

    def mark_integrated!(attrs)
      transition_to!(:integrated, attrs)
    end

    def mark_paid!
      transition_to!(:paid)
    end

    def mark_unpaid!
      transition_to!(:unpaid)
    end

    def stopped?
      in_state?(:incomplete, :rejected, :unpaid)
    end

    def inactive?
      in_state?(*ASP::PaymentRequestStateMachine::INACTIVE_STATES)
    end

    def active?
      !inactive?
    end

    def rejection_reason
      last_transition.metadata["Motif rejet"]
    end

    private

    def single_active_payment_request_per_pfmp
      return unless pfmp.payment_requests.where.not(id: id).active.any?

      errors.add(:base, "There can only be one active payment request per Pfmp.")
    end
  end
end
