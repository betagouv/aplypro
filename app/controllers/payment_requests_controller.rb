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

    redirect_back_or_to class_schooling_pfmp_path(@classe, @schooling, @pfmp),
                        notice: t("flash.pfmps.create_payment_request", name: @schooling.student.full_name)
  end
end
