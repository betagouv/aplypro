# frozen_string_literal: true

class FixAdminNumberJob < ApplicationJob
  class SuffixExhaustedError < StandardError; end

  MAX_SUFFIX = 99
  SUFFIX_PATTERN = /\d{2}\z/

  queue_as :payments
  sidekiq_options retry: false

  def perform(pfmp_id)
    pfmp = Pfmp.find(pfmp_id)

    PfmpManager.new(pfmp).fix_administrative_number_and_resubmit!(next_administrative_number(pfmp))
  end

  private

  def next_administrative_number(pfmp)
    old_number = pfmp.administrative_number
    suffix = old_number[SUFFIX_PATTERN]
    prefix = old_number.delete_suffix(suffix)

    new_suffix = [suffix.to_i, pfmp.schooling.pfmps.count].max + 1
    raise SuffixExhaustedError, "#{prefix} has exhausted its 2-digit suffix space" if new_suffix > MAX_SUFFIX

    "#{prefix}#{new_suffix.to_s.rjust(2, '0')}"
  end
end
