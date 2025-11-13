# frozen_string_literal: true

module Academic
  class EstablishmentsController < Academic::ApplicationController
    before_action :find_establishment

    helper_method :current_establishment

    def show
      @directors = User.joins(establishment_user_roles: :establishment)
                       .where(establishment_user_roles: { role: :dir, establishment_id: @etab.id })
                       .distinct
      @establishment_data = establishment_data_from_report
    end

    private

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

      { @etab.uai => data }
    end
  end
end
