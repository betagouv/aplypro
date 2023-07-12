# frozen_string_literal: true

class FetchEstablishmentJob < ApplicationJob
  queue_as :default

  def perform(etab)
    etab.fetch_data!
  end
end
