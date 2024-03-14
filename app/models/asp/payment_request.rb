# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    PAYMENT_STAGES = [
      %i[pending ready incomplete],
      %i[sent integrated rejected],
      %i[paid unpaid]
    ].freeze

    belongs_to :asp_request, class_name: "ASP::Request", optional: true
    belongs_to :pfmp

    has_one :student, through: :pfmp
    has_one :schooling, through: :pfmp

    has_many :asp_payment_request_transitions,
             class_name: "ASP::PaymentRequestTransition",
             dependent: :destroy,
             inverse_of: :asp_payment_request

    scope :pending_or_ready, -> { in_state(:pending, :ready) }
    scope :sent_or_integrated, -> { in_state(:sent, :integrated) }

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

    def self.grouped_states
      PAYMENT_STAGES
        .map { |stages| [stages[0..-2], [stages.last]] }
        .reduce(&:concat)
    end

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
  end
end
