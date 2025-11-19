# frozen_string_literal: true

module Academic
  class EstablishmentsController < Academic::ApplicationController
    include UserFiltering

    before_action :find_establishment

    helper_method :current_establishment

    def show
      @directors = User.joins(establishment_user_roles: :establishment)
                       .where(establishment_user_roles: { role: :dir, establishment_id: @etab.id })
                       .distinct
      @establishment_data = establishment_data_from_report
    end

    def users
      @search_query = normalize_search_query
      @users = filtered_establishment_users
      @establishment_eurs_by_user = load_establishment_user_roles
    end

    private

    def filtered_establishment_users
      User.joins(establishment_user_roles: :establishment)
          .where(establishment_user_roles: { establishment_id: @etab.id })
          .then { |relation| apply_search(relation) }
          .then { |relation| filter_by_role(relation) }
          .then { |relation| apply_user_sorting(relation) }
          .page(params[:page])
          .per(users_per_page)
    end

    def current_establishment
      @current_establishment ||= @etab
    end

    def find_establishment
      @etab = Establishment.joins(:classes)
                           .where(academy_code: selected_academy,
                                  "classes.school_year_id": selected_school_year)
                           .find(params.require(:id))
      @establishment_facade = EstablishmentFacade.new(current_establishment, selected_school_year)
    end

    def establishment_data_from_report
      report = current_report
      raise ReportNotFoundError, selected_school_year if report.nil?

      extractor = Academic::EstablishmentsReportExtractor.new(report, selected_academy, selected_school_year)
      data = extractor.extract_single_establishment_data(@etab.uai)

      return {} if data.nil?

      { @etab.uai => data }
    end

    def load_establishment_user_roles
      EstablishmentUserRole
        .where(user_id: @users.reorder(nil).pluck(:id), establishment_id: @etab.id)
        .includes(:establishment)
        .group_by(&:user_id)
    end
  end
end
