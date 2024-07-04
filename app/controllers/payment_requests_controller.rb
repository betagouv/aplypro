# frozen_string_literal: true

class PaymentRequestsController < ApplicationController
  include RoleCheck
  include PfmpResource

  before_action :check_director,
                :update_confirmed_director!,
                :check_confirmed_director,
                :set_classe,
                :set_schooling,
                :set_pfmp

  def create
    PfmpManager.new(@pfmp).create_new_payment_request!

    redirect_back_or_to school_year_class_schooling_pfmp_path(selected_school_year.start_year,
                                                              @classe,
                                                              @schooling,
                                                              @pfmp),
                        notice: t("flash.payment_requests.create", name: @schooling.student.full_name)
  end

  def update
    result = PfmpManager.new(@pfmp).retry_incomplete_payment_request!

    redirect_back_or_to school_year_class_schooling_pfmp_path(selected_school_year.start_year,
                                                              @classe,
                                                              @schooling,
                                                              @pfmp),
                        notice: t("flash.payment_requests.mark_ready.#{result ? 'success' : 'failure'}",
                                  name: @schooling.student.full_name)
  end
end
