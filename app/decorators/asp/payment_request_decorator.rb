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

    PAYMENT_STAGES = [
      %i[pending ready incomplete],
      %i[sent integrated rejected],
      %i[paid unpaid]
    ].freeze

    def status_badge
      dsfr_badge(status: BADGE_STATE_MAPPING[current_state.to_sym], classes: ["fr-badge--sm"]) do
        status
      end
    end

    def all_status_badges
      current_stages.map do |state|
        disabled = "disabled" if current_state_symbol != state

        dsfr_badge(status: BADGE_STATE_MAPPING[state], classes: ["fr-badge--sm", disabled]) do
          I18n.t("payment_requests.state.#{state}")
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

    def status
      t("payment_requests.state.#{current_state}")
    end

    def status_explanation
      tag.span(t("payment_requests.state_explanations.#{current_state}", **status_explanation_args))
    end

    def rejection_reason
      msg = last_transition.metadata["Motif rejet"]

      if (error = ASP::ErrorsDictionary.definition(msg))
        I18n.t("asp.errors.#{error[:key]}")
      else
        msg
      end
    end

    def status_explanation_args
      case current_state
      when "rejected"
        { rejection_reason: rejection_reason }
      when "unpaid"
        { unpaid_reason: unpaid_reason }
      else
        {}
      end
    end
  end
end
