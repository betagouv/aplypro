# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    include ::StateMachinable

    # Virtual attribute declared solely in the context of ready transition validation
    attr_accessor :ready_state_validation

    belongs_to :asp_request, class_name: "ASP::Request", optional: true
    belongs_to :asp_payment_return, class_name: "ASP::PaymentReturn", optional: true

    belongs_to :pfmp

    has_one :student, through: :pfmp
    has_one :schooling, through: :pfmp

    validate :single_active_payment_request_per_pfmp, on: %i[create update]

    scope :active, -> { not_in_state(*ASP::PaymentRequestStateMachine::TERMINATED_STATES) }
    scope :terminated, -> { in_state(*ASP::PaymentRequestStateMachine::TERMINATED_STATES) }
    scope :ongoing, -> { in_state(*ASP::PaymentRequestStateMachine::ONGOING_STATES) }
    scope :failed, -> { in_state(*ASP::PaymentRequestStateMachine::FAILED_STATES) }

    scope :latest_per_pfmp, lambda {
      subquery = ASP::PxaymentRequest
                 .select("DISTINCT ON (pfmp_id) *")
                 .order("pfmp_id", "created_at DESC")
                 .to_sql
      from("(#{subquery}) as asp_payment_requests")
    }

    # Use this method if moving the object to another state in case of failure
    # is irrelevant and/or if you dont care about storing the errors in metadata
    def mark_ready!
      transition_to!(:ready)
    end

    # This method has the following advantages:
    # - avoid raising guard error
    # - move to state incomplete
    # - store the reasons of incompletion in metadata
    def attempt_to_transition_to_ready!
      if can_transition_to?(:ready) # Triggers guards that trigger validator
        mark_ready!(:ready)
      else
        mark_incomplete!({ incomplete_reasons: errors })
      end
    end

    def mark_as_sent!
      transition_to!(:sent)
    end

    def reject!(metadata)
      transition_to!(:rejected, metadata)
    end

    def mark_incomplete!(metadata)
      transition_to!(:incomplete, metadata)
    end

    def mark_integrated!(metadata)
      transition_to!(:integrated, metadata)
    end

    def mark_paid!(metadata, record)
      update!(asp_payment_return: record)

      transition_to!(:paid, metadata)
    end

    def mark_unpaid!(metadata, record)
      update!(asp_payment_return: record)

      transition_to!(:unpaid, metadata)
    end

    def terminated?
      in_state?(*ASP::PaymentRequestStateMachine::TERMINATED_STATES)
    end

    def failed?
      in_state?(*ASP::PaymentRequestStateMachine::FAILED_STATES)
    end

    def active?
      !terminated?
    end

    def rejection_reason
      last_transition.metadata["Motif rejet"]
    end

    def unpaid_reason
      last_transition.metadata["PAIEMENT"]["LIBELLEMOTIFINVAL"]
    end

    private

    def single_active_payment_request_per_pfmp
      return if pfmp.nil?

      return unless pfmp.payment_requests.excluding(self).active.any?

      errors.add(:base, "There can only be one active payment request per Pfmp.")
    end
  end
end
