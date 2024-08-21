# frozen_string_literal: true

class PollPaymentsServerJob < ApplicationJob
  queue_as :payments

  sidekiq_options retry: false

  def perform
    dir = ASP::Server.get_all_files!

    Dir.each_child(dir) do |filename|
      next if filename == ".keep" # these are the Git-keep files of our local dev

      file = File.open(File.join(dir, filename))

      ASP::FileSaver.new(file).persist_file!

      ProcessASPResponseFileJob.perform_later(filename)

      ASP::Server.remove_file!(filename: filename)
    rescue ASP::Errors::UnmatchedResponseFile => e
      Sentry.capture_exception(e)
      next
    end
  end
end
