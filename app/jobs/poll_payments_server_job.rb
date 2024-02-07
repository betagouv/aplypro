# frozen_string_literal: true

class PollPaymentsServerJob < ApplicationJob
  queue_as :default

  def perform
    dir = ASP::Server.get_all_files!

    Dir.each_child(dir) do |file|
      ASP::FileReader.new(File.join(dir, file)).parse!
    end
  end
end
