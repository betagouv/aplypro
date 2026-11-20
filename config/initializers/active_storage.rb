# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Keep files available to downloads that selected them before replacement.
  ActiveStorage::PurgeJob.before_enqueue do |job|
    job.scheduled_at ||= 1.hour.from_now
  end
end
