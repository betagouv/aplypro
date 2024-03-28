# frozen_string_literal: true

module UserLogger
  extend ActiveSupport::Concern

  protected

  def log_user
    logger.info "Current user id: #{current_user.id}"
  end
end
