# frozen_string_literal: true

module ASP
  module PaymentRequestDecorator
    BADGE_STATE_MAPPING = {
      pending: :new,
      ready: :new,
      incomplete: :error,
      sent: :info,
      integrated: :info,
      rejected: :error,
      paid: :success,
      unpaid: :error
    }.freeze

    ORDERED_FAILED_STATES = %i[incomplete rejected unpaid].freeze

    PAYMENT_STAGES = [
      %i[pending ready incomplete],
      %i[sent integrated rejected],
      %i[paid unpaid]
    ].freeze

    def status_badge
      dsfr_badge(status: BADGE_STATE_MAPPING[current_state.to_sym], classes: ["fr-badge--sm"]) do
        status(current_state.to_sym)
      end
    end

    def all_status_badges
      current_stages.map do |state|
        disabled = "disabled" if current_state_symbol != state

        dsfr_badge(status: BADGE_STATE_MAPPING[state], classes: ["fr-badge--sm", disabled]) do
          status(state)
        end
      end
    end

    def current_stages
      PAYMENT_STAGES.map do |states_group|
        if states_group.include? current_state_symbol
          current_state_symbol
        else
          states_group.first
        end
      end
    end

    def current_state_symbol
      current_state.to_sym
    end

    def status(state)
      state = "waiting" if state.eql?(:pending) && !eligible_for_retry?

      t("payment_requests.state.#{state}")
    end

    def status_explanation # rubocop:disable Metrics/AbcSize
      if recovery?
        return t("payment_requests.state_explanations.recovery",
                 date: last_transition.metadata["ORDREREVERSEMENT"]["DATEOREFFECTIF"])
      end

      args = status_explanation_args.values.first
      return t("payment_requests.state_explanations.#{current_state}") if args.nil?

      reason = prepare_reason(args)
      t("payment_requests.state_explanations.#{current_state}",
        **{ status_explanation_args.keys.first => reason }).html_safe
    end

    def failure_reasons
      ORDERED_FAILED_STATES.each do |state|
        return public_send("#{state}_reason") if in_state?(state)
      end
      nil
    end

    def rejected_reason
      msg = last_transition.metadata["Motif rejet"]

      if (error = ASP::ErrorsDictionary.definition(msg))
        I18n.t("asp.errors.#{error[:key]}")
      else
        msg
      end
    end

    def unpaid_reason
      last_transition.metadata["PAIEMENT"]["LIBELLEMOTIFINVAL"]
    end

    def incomplete_reason
      last_transition.metadata["incomplete_reasons"]["ready_state_validation"]
    end

    def prepare_reason(args)
      if args.is_a?(Array)
        args.size > 1 ? build_ul_from(args) : args.first
      else
        args
      end
    end

    def build_ul_from(args)
      tag.ul do
        args.map { |reason| tag.li(reason) }.join.html_safe # rubocop:disable Rails/OutputSafety
      end
    end

    # Argument passed to the locale for interpolation
    def status_explanation_args
      { "#{current_state}_reason": failure_reasons }
    end
  end
end
