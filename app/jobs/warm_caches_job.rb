# frozen_string_literal: true

class WarmCachesJob < ApplicationJob
  queue_as :payments

  def perform
    CacheWarmer::AcademicDataService.warm_all
  end
end
