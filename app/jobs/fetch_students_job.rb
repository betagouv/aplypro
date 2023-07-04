# frozen_string_literal: true

class FetchStudentsJob < ApplicationJob
  queue_as :default

  def perform(etab)
    StudentApi.fetch_students!(etab)
  end
end
