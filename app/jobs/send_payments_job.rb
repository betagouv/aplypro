# frozen_string_literal: true

class SendPaymentsJob < ApplicationJob
  queue_as :default

  def perform(payment_ids)
    payments = Payment.where(id: payment_ids)

    requests = ASP::PaymentRequest
               .in_state(:ready)
               .where(payment: payment_ids)

    request = ASP::Request.with_payments(payments, ASP::Entities::Fichier)

    request.send!(ASP::Server)

    # FIXME: this is bound to be very slow if we're sending thousands
    # of payments at once; one solution is to use a separate job (say:
    # MarkPaymentProcessedJob.perform_all(ids)) but that only allows
    # this one to finish quicker.
    #
    # On the other hand we can't really make it much faster: we have
    # to trigger this transition, along with the database ripple.
    requests.find_each do |req|
      req.mark_as_sent!(request)
    end
  end
end
