# frozen_string_literal: true

module Rectifiable
  extend ActiveSupport::Concern

  included do
    rescue_from PfmpManager::RectificationAmountThresholdNotReachedError do
      @student = @pfmp.student
      flash.now[:alert] = t(
        "flash.pfmps.rectification.threshold_not_reached",
        threshold: PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      )
      render :confirm_rectification, status: :unprocessable_entity
    end

    rescue_from PfmpManager::RectificationAmountZeroError do
      @student = @pfmp.student
      flash.now[:alert] = t("flash.pfmps.rectification.zero_difference")
      render :confirm_rectification, status: :unprocessable_entity
    end
  end

  def confirm_rectification
    if @pfmp.can_transition_to?(:rectified)
      @student = @pfmp.student
      render :confirm_rectification
    else
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  alert: t("flash.pfmps.rectification.cannot_rectify")
    end
  end

  def rectify
    if @pfmp.can_transition_to?(:rectified)
      @student = @pfmp.student
      PfmpManager.new(@pfmp).rectify_and_update_attributes!(pfmp_params, address_params)
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  notice: t("flash.pfmps.rectification.rectified")
    else
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  alert: t("flash.pfmps.rectification.cannot_rectify")
    end
  rescue ActiveRecord::RecordInvalid
    render :confirm_rectification, status: :unprocessable_entity
  end
end
