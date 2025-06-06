# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord # rubocop:disable Metrics/ClassLength
    TRANSITION_CLASS = ASP::PaymentRequestTransition
    STATE_MACHINE_CLASS = ASP::PaymentRequestStateMachine

    TRANSITION_RELATION_NAME = :asp_payment_request_transitions
    FUNDING_ISSUE = "Funding not currently available"
    RETRYABLE_INCOMPLETE_VALIDATION_TYPES = %i[
      needs_abrogated_attributive_decision
      missing_attributive_decision
    ].freeze

    include ::StateMachinable

    has_many :asp_payment_request_transitions, class_name: "ASP::PaymentRequestTransition", dependent: :destroy,
                                               inverse_of: :asp_payment_request

    # Virtual attribute declared solely in the context of ready transition validation
    attr_accessor :ready_state_validation

    belongs_to :asp_request, class_name: "ASP::Request", optional: true
    belongs_to :asp_payment_return, class_name: "ASP::PaymentReturn", optional: true
    belongs_to :rib, optional: true

    belongs_to :pfmp

    validates :pfmp, uniqueness: { conditions: -> { ongoing } }

    has_one :student, through: :pfmp
    has_one :schooling, through: :pfmp

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

    scope :for_year, lambda { |start_year|
                       joins(pfmp: { schooling: { classe: :school_year } })
                         .where(school_year: { start_year: start_year })
                     }

    class << self
      # NOTE: to_consider is a temporary scope to do some basic
      # pre-filtering on the payment requests we're trying to mark
      # ready. It's a safety net for the coming weeks and should be
      # removed soon. It also holds some filtering logic which we
      # needs further thinking from us like some schoolings without
      # administrative_number.
      def to_consider
        in_state(:pending)
          .joins(:schooling, :pfmp, :student)
          .merge(Schooling.with_attributive_decisions)
          .merge(Schooling.with_administrative_number)
          .merge(Schooling.with_one_character_attributive_decision_version)
          .merge(Student.with_rib)
          .merge(Pfmp.finished)
      end
    end

    # XXX: Some records dont have a rib attached (yet)
    def rib_with_fallback
      rib || student.rib(pfmp.establishment)
    end

    def mark_ready!
      transition_to!(:ready)
    rescue ASP::Errors::IncompletePaymentRequestError
      mark_incomplete!({ incomplete_reasons: errors })
    rescue ASP::Errors::FundingNotAvailableError
      unless last_transition.metadata["pending_reasons"] == FUNDING_ISSUE
        mark_pending!({ pending_reason: FUNDING_ISSUE })
      end
    end

    def mark_pending!(metadata)
      transition_to!(:pending, metadata)
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

    def ongoing?
      in_state?(*ASP::PaymentRequestStateMachine::ONGOING_STATES)
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

    def recovery?
      last_transition.present? && last_transition.metadata["ORDREREVERSEMENT"].present?
    end

    def eligible_for_incomplete_auto_retry?
      return false unless in_state?(:incomplete)

      retryable_messages = RETRYABLE_INCOMPLETE_VALIDATION_TYPES.map do |r|
        I18n.t("activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.#{r}")
      end
      last_transition.metadata["incomplete_reasons"]["ready_state_validation"].intersect?(retryable_messages)
    end

    def eligible_for_rejected_auto_retry?
      return false unless in_state?(:rejected)

      !rejected_error_code.eql?(:fallback_message)
    end

    def rejected_error_code
      msg = last_transition.metadata["Motif rejet"]
      ASP::ErrorsDictionary.rejected_definition(msg)
    end

    def payable?
      schooling.classe.mef.funding_available?
    end

    def reconstructed_iban
      return nil if !in_state?(:paid) || recovery?

      coordpaie = last_transition.metadata["PAIEMENT"]["COORDPAIE"]
      zonebban = coordpaie["ZONEBBAN"]
      cle = coordpaie["CLECONTROL"]
      code_pays = coordpaie["CODEISOPAYS"]

      "#{code_pays}#{cle}#{zonebban}"
    end
  end
end
