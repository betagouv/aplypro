# frozen_string_literal: true

module ASP
  module PaymentRequestDecorator
    BADGE_STATE_MAPPING = {
      pending: :new,
      incomplete: :error,
      ready: :success,
      sent: :warning,
      rejected: :error,
      integrated: :info
    }.freeze

    def badge
      dsfr_badge(status: BADGE_STATE_MAPPING[current_state.to_sym]) do
        status
      end
    end

    def status
      t("payment_requests.state.#{current_state}")
    end

    def status_explanation
      tag.span(t("payment_requests.status_explanation.#{current_state}", **status_explanation_args))
    end

    def status_explanation_args
      case current_state
      when "rejected"
        { reject_reason: reject_reason }
      else
        {}
      end
    end

    def reject_reason
      last_transition.metadata["Motif rejet"]
    end
  end
end
