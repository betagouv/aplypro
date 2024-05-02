# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    TRANSITION_CLASS = ASP::PaymentRequestTransition
    STATE_MACHINE_CLASS = ASP::PaymentRequestStateMachine

    TRANSITION_RELATION_NAME = :asp_payment_request_transitions

    include ::StateMachinable

    has_many :asp_payment_request_transitions, class_name: "ASP::PaymentRequestTransition", dependent: :destroy,
                                               inverse_of: :asp_payment_request

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
      subquery = ASP::PaymentRequest
                 .select("DISTINCT ON (pfmp_id) *")
                 .order("pfmp_id", "created_at DESC")
                 .to_sql
      from("(#{subquery}) as asp_payment_requests")
    }

    class << self
      # NOTE: to_consider is a temporary scope to do some basic
      # pre-filtering on the payment requests we're trying to mark
      # ready. It's a safety net for the coming weeks and should be
      # removed soon. It also holds some filtering logic which we
      # needs further thinking from us like some schoolings without
      # administrative_number.
      def to_consider(max_date)
        in_state(:pending)
          .joins(:schooling, :pfmp, :student)
          .merge(Schooling.with_attributive_decisions)
          .merge(Schooling.with_administrative_number)
          .merge(Schooling.with_one_character_attributive_decision_version)
          .merge(Student.with_rib)
          .merge(Pfmp.finished)
          .where("pfmps.end_date <= ?", max_date)
      end
    end

    def mark_ready!
      transition_to!(:ready)
    rescue ASP::Errors::IncompletePaymentRequestError
      mark_incomplete!({ incomplete_reasons: errors })
    end

    def mark_sent!
      transition_to!(:sent)
    end

    def mark_rejected!(metadata)
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

    def unpaid_reason
      last_transition.metadata["PAIEMENT"]["LIBELLEMOTIFINVAL"]
    end

    def incomplete_reason
      last_transition.metadata["incomplete_reasons"]["ready_state_validation"]
    end

    private

    def single_active_payment_request_per_pfmp
      return if pfmp.nil?

      return unless pfmp.payment_requests.excluding(self).active.any?

      errors.add(:base, "There can only be one active payment request per Pfmp.")
    end
  end
end
