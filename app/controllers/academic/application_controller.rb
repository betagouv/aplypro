# frozen_string_literal: true

module Academic
  class ApplicationController < ActionController::Base
    include UserLogger
    include PageTitle
    include SelectedSchoolYear

    layout "application"

    before_action :authenticate_academic_user!,
                  :check_selected_academy,
                  except: %i[login logout]

    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

    helper_method :current_user, :selected_academy, :authorised_academy_codes, :selected_school_year

    def home
      @establishments_for_academy = Establishment.joins(:classes)
                                                 .where(academy_code: selected_academy,
                                                        "classes.school_year_id": selected_school_year)
                                                 .distinct

      @nb_schoolings_per_establishments = @establishments_for_academy.left_joins(:schoolings)
                                                                     .group(:uai)
                                                                     .count(:schoolings)

      @amounts_per_establishments = @establishments_for_academy.map do |establishment|
        pfmps = establishment.pfmps
                             .joins(schooling: { classe: :school_year })
                             .where(classes: { school_year_id: selected_school_year })

        validated_amount = pfmps
                           .joins(:transitions)
                           .where(pfmp_transitions: { to_state: "validated", most_recent: true })
                           .sum(:amount)

        paid_amount = pfmps
                      .joins(payment_requests: :asp_payment_request_transitions)
                      .where(asp_payment_request_transitions: { to_state: "paid", most_recent: true })
                      .sum(:amount)

        {
          uai: establishment.uai,
          payable_amount: validated_amount,
          paid_amount: paid_amount
        }
      end.index_by { |stats| stats[:uai] }
    end

    def login
      @inhibit_banner = true
    end

    def logout
      sign_out(current_academic_user)
      reset_session

      redirect_to after_sign_out_path_for(:academic_user)
    end

    protected

    def after_sign_out_path_for(_resource)
      new_academic_user_session_path
    end

    def current_user
      current_academic_user
    end

    def set_overrides
      @inhibit_nav = true
      @inhibit_title = true
      @logout_path = :destroy_academic_user_session
    end

    def selected_academy
      @selected_academy ||= session[:selected_academy]
    end

    def authorised_academy_codes
      @authorised_academy_codes ||= session[:academy_codes]
    end

    private

    def check_selected_academy
      # TODO: verify that selected academy is authorised
      return unless academic_user_signed_in?

      redirect_to select_academy_academic_users_path(current_user) if selected_academy.nil?
    end
  end
end
