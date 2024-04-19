# frozen_string_literal: true

class PollPaymentsServerJob < ApplicationJob
  queue_as :payments

  def perform
    dir = ASP::Server.get_all_files!

    Dir.each_child(dir) do |filename|
      next if filename == ".keep" # these are the Git-keep files of our local dev

      file = File.open(File.join(dir, filename))

      handler = ASP::FileHandler.new(file)

      begin
        handler.parse!
      rescue ASP::Errors::ResponseFileParsingError, ASP::Errors::UnmatchedResponseFile => e
        Sentry.capture_exception(e)
      ensure
        ASP::Server.remove_file!(filename: filename) if handler.file_saved?
      end
    end
  end
end
