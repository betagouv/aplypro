# frozen_string_literal: true

class WarmCachesJob < ApplicationJob
  queue_as :default

  def perform
    CacheWarmer::AcademicDataService.warm_all
  end
end
