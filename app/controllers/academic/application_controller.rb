# frozen_string_literal: true

module Academic
  class ApplicationController < ActionController::Base
    include UserLogger
    include PageTitle
    include SelectedSchoolYear

    layout "academic"

    before_action :authenticate_academic_user!,
                  :check_selected_academy,
                  except: %i[login logout]

    before_action :log_user,
                  :set_overrides,
                  :infer_page_title

    helper_method :current_user, :selected_academy, :authorised_academy_codes, :selected_school_year

    def home
      establishments = Establishment.joins(:classes)
                                    .where(academy_code: selected_academy,
                                           "classes.school_year_id": selected_school_year)
                                    .distinct

      @establishments_data = establishments_data_summary(establishments.pluck(:id))
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

    # NOTE: the schena of this entity is a draft
    def establishments_data_summary(ids) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      cache_key = "establishments_data_summary/#{ids.sort.join('-')}/school_year/#{selected_school_year}"

      Rails.cache.fetch(cache_key, expires_in: 2.hours) do
        data = {}
        Establishment.where(id: ids).find_each do |establishment|
          pfmps = establishment.pfmps
                               .joins(schooling: { classe: :school_year })
                               .where(classes: { school_year_id: selected_school_year })

          schooling_count = establishment.schoolings.count
          validated_amount = pfmps.joins(:transitions)
                                  .where(pfmp_transitions: { to_state: "validated", most_recent: true })
                                  .sum(:amount)
          paid_amount = pfmps.joins(payment_requests: :asp_payment_request_transitions)
                             .where(asp_payment_request_transitions: { to_state: "paid", most_recent: true })
                             .sum(:amount)

          data[establishment.uai] = establishment.attributes.symbolize_keys.merge({
                                                                                    schooling_count: schooling_count,
                                                                                    payable_amount: validated_amount,
                                                                                    paid_amount: paid_amount
                                                                                  })
        end
        data.sort_by { |_uai, etab_data| -etab_data[:paid_amount] }.to_h
      end
    end
  end
end
