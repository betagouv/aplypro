# frozen_string_literal: true

module Academic
  class EstablishmentsController < Academic::ApplicationController
    before_action :find_establishment

    helper_method :current_establishment

    def show
      @establishment_data = establishments_data_summary([@etab.id])
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
  end
end
