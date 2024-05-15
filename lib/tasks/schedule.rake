# frozen_string_literal: true

namespace :schedule do
  # according to https://doc.scalingo.com/platform/app/task-scheduling/scalingo-scheduler
  desc "Regenerates the cron schedule for Scalingo"
  task regenerate: :environment do
    schedule = `bundle exec whenever`

    commands = schedule
               .lines
               .map(&:strip)
               .reject { |line| line.start_with?("#") }
               .compact_blank
               .map { |c| { command: c } }

    Rails.root.join("cron.json").write(JSON.pretty_generate(jobs: commands))
  end
end
