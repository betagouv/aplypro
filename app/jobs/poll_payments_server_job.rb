# frozen_string_literal: true

class PollPaymentsServerJob < ApplicationJob
  queue_as :default

  def perform
    dir = ASP::Server.get_all_files!

    Dir.each_child(dir) do |file|
      next if file == ".keep" # these are the Git-keep files of our local dev

      handler = ASP::FileHandler.new(File.join(dir, file))

      begin
        handler.parse!
      rescue ASP::Errors::ResponseFileParsingError, ASP::Errors::UnmatchedResponseFile => e
        Sentry.capture_exception(e)
      ensure
        ASP::Server.remove_file!(path: file) if handler.file_saved?
      end
    end
  end
end
