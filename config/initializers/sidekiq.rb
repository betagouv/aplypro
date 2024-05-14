# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.capsule("single-threaded") do |cap|
    cap.concurrency = 1
    cap.queues = %w[payments_serial]
  end
end
