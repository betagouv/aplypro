# frozen_string_literal: true

module UserLogger
  extend ActiveSupport::Concern

  protected

  def log_user
    if current_user
      logger.info "Current #{current_user.class} id: #{current_user.id}"
    else
      logger.info "No logged User."
    end
  end
end
