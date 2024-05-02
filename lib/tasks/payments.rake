# frozen_string_literal: true

# ASSOCIATIVE_RIB_IDS = YAML.load(File.read("associative_rib_ids.yml")))

# ConsiderPaymentRequestsJob.perform_later(DATE_BUTOIR)

# ASP::PaymentRequest.in_state(:ready).count # check until 7000

# requests = ASP::PaymentRequest
#            .in_state(:ready)
#            .joins(student: :rib)
#            .where.not("ribs.id": ASSOCIATIVE_RIB_IDS)
#            .order("pfmps.end_date")

# SendPaymentRequestsJob.perform_later(requests.to_a)

# ASP::PaymentRequest.joins(ASP::PaymentRequest.most_recent_transition_join).group(:to_state).count

# Check si y'a moins de 100k en cours cette semaine
# ASP::Request.total_requests_sent_this_week
