# frozen_string_literal: true

class ConsiderPaymentRequestsJob < ApplicationJob
  queue_as :payments

  def perform
    requests = ASP::PaymentRequest.to_consider
    correctable = requests.select { |r| had_recovery?(r.pfmp.student) }

    ActiveJob.perform_all_later(*build_jobs(requests, correctable))
  end

  private

  def build_jobs(requests, correctable)
    jobs = requests.map { |r| PreparePaymentRequestJob.new(r) }
    jobs << SendCorrectionAdresseJob.new(correctable.map { |r| r.pfmp.id }) if correctable.any?
    jobs
  end

  def had_recovery?(student)
    student.pfmps.any? { |pfmp| pfmp.payment_requests.any?(&:recovery?) }
  end
end
