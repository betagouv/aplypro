# frozen_string_literal: true

class SendCorrectionAdresseJob < ApplicationJob
  queue_as :payments
  sidekiq_options retry: false

  RNVP_STUDENT_BATCH_THRESHOLD = 10

  def perform(pfmp_ids)
    payment_requests = Pfmp.where(id: pfmp_ids)
                           .filter_map { |pfmp| pfmp.payment_requests.order(:created_at).last }

    return if payment_requests.empty?

    enrich_with_rnvp!(payment_requests.map(&:student).uniq)

    ASP::Request.create!(correction_adresse: true).send_correction_adresse!(payment_requests)
  end

  private

  def enrich_with_rnvp!(students)
    rnvp = Omogen::Rnvp.new
    data = fetch_rnvp_data(rnvp, students)
    students.each do |s|
      s.rnvp_data = data[s.id] || raise(ASP::Errors::MissingRnvpDataError, "No RNVP data for student #{s.id}")
    end
  end

  def fetch_rnvp_data(rnvp, students)
    if students.count > RNVP_STUDENT_BATCH_THRESHOLD
      rnvp.addresses(students).index_by { |address| address[:id] }
    else
      students.to_h { |s| [s.id, rnvp.address(s)] }
    end
  end
end
