# frozen_string_literal: true

require "net/http"
require "uri"

# the Fetcher class just downloads something and puts it in the /tmp
# folder. I couldn't find a library that simply did that.
class Fetcher
  DESTINATION = Rails.root.join("tmp")

  def initialize(url)
    @logger = ActiveSupport::TaggedLogging.new(Rails.logger).tagged("DATA")
    @uri = URI(url)
    @target = DESTINATION.join(@uri.path)

    @logger.debug("Fetcher pointed at #{@uri}")
  end

  def read
    download if !on_disk?

    File.read(@target)
  end

  def download
    @logger.debug("Fetching from #{@uri}...")
    raw = Net::HTTP.get(@uri).force_encoding("UTF-8")

    File.write(@target, raw)
  end

  def on_disk?
    File.exist?(@target)
  end
end
