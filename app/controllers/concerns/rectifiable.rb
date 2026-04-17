# frozen_string_literal: true

module Rectifiable
  extend ActiveSupport::Concern

  included do
    rescue_from PfmpManager::RectificationValidationError do |error|
      @student = @pfmp.student
      @pfmp.errors.add(:base, error.message)
      render :confirm_rectification, status: :unprocessable_content
    end

    rescue_from PfmpManager::RectificationAmountThresholdNotReachedError do
      @student = @pfmp.student
      flash.now[:alert] = t(
        "flash.pfmps.rectification.threshold_not_reached",
        threshold: PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      )
      render :confirm_rectification, status: :unprocessable_content
    end

    rescue_from PfmpManager::RectificationAmountZeroError do
      @student = @pfmp.student
      flash.now[:alert] = t("flash.pfmps.rectification.zero_difference")
      render :confirm_rectification, status: :unprocessable_content
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
      perform_rectification
      redirect_to_pfmp(notice: t("flash.pfmps.rectification.rectified"))
    else
      redirect_to_pfmp(alert: t("flash.pfmps.rectification.cannot_rectify"))
    end
  rescue ActiveRecord::RecordInvalid
    render :confirm_rectification, status: :unprocessable_content
  end

  private

  def perform_rectification
    @student = @pfmp.student
    check_pfmp_schooling_dates!
    Pfmp.transaction do
      PfmpManager.new(@pfmp).rectify_and_update_attributes!(pfmp_params, address_params)
      @pfmp.reload
      check_negative_rectification!
    end
    @pfmp.latest_payment_request.mark_ready!
  end

  def check_pfmp_schooling_dates!
    temp_pfmp = @pfmp.dup.tap { |p| p.assign_attributes(pfmp_params.slice(:start_date, :end_date)) }
    return if temp_pfmp.within_schooling_dates?

    raise_rectification_validation_error(:pfmp_outside_schooling_dates)
  end

  def check_negative_rectification!
    return unless @pfmp.paid_amount.present? && @pfmp.amount.positive? && @pfmp.amount < @pfmp.paid_amount

    raise_rectification_validation_error(:negative_rectification)
  end

  def raise_rectification_validation_error(error_key)
    raise PfmpManager::RectificationValidationError, error_key
  end

  def redirect_to_pfmp(flash_options)
    redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                **flash_options
  end
end
