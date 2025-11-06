# frozen_string_literal: true

module Academic
  class ReportsController < Academic::ApplicationController # rubocop:disable Metrics/ClassLength
    include Zipline

    before_action :set_report_context, only: %i[show global export establishments_table]
    before_action :set_data_extractor, only: %i[show global export establishments_table]

    def index
      infer_page_title
      @inhibit_banner = true
      @inhibit_breadcrumb = true
      @school_years = SchoolYear.order(start_year: :desc)
      @selected_school_year_id = params[:school_year_id]

      @reports = Report.includes(:school_year).order(created_at: :desc)
      @reports = @reports.where(school_year_id: @selected_school_year_id) if @selected_school_year_id.present?
    end

    def show
      prepare_statistics_data
    end

    def global
      return redirect_unauthorized unless current_user.admin?

      prepare_global_statistics_data
    end

    def export
      return redirect_unauthorized unless current_user.admin?

      zipline(export_files, export_filename)
    end

    def establishments_table
      set_report_data

      if params[:view_type] == "global"
        return redirect_unauthorized unless current_user.admin?

        @establishments_data = @data_extractor.extract(:establishments_data)
      else
        @establishments_data = filtered_establishments_data_from_report
      end

      @establishments_hash = load_establishments_hash

      respond_to do |format|
        format.html { render "establishments_table", layout: false }
      end
    end

    private

    def set_report_context
      infer_page_title
      @inhibit_banner = true
      @inhibit_breadcrumb = true
      @report = Report.select(:id, :school_year_id, :created_at).find(params[:id])
      @current_year = @report.school_year.start_year
      @stats = Stats::Main.new(@current_year)

      @comparable_reports = Report.select(:id, :school_year_id, :created_at)
                                  .where(school_year: @report.school_year)
                                  .where(created_at: ...@report.created_at)
                                  .order(created_at: :desc)

      @comparison_report = determine_comparison_report
    end

    def set_data_extractor
      @data_extractor = Reports::DataExtractor.new(@report)
    end

    def redirect_unauthorized
      redirect_to academic_report_path(params[:id]), alert: t("academic.reports.export.unauthorized")
    end

    def prepare_statistics_data
      @academy_stats = academy_statistics
      set_report_data
      @academy_stats_progressions = calculate_academy_progressions
    end

    def prepare_global_statistics_data
      set_report_data
      @global_stats = Reports::StatsExtractor.extract_global_stats(@report)
      @global_stats_progressions = calculate_global_progressions
    end

    def set_report_data
      extracted_data = @data_extractor.extract(:global_data, :bops_data, :menj_academies_data)
      @global_data = extracted_data[:global_data]
      @bops_data = extracted_data[:bops_data]
      @menj_academies_data = extracted_data[:menj_academies_data]
      @indicators_metadata = @stats.indicators_with_metadata
    end

    def academy_statistics
      Academic::StatsExtractor.new(@report, selected_academy).extract_stats_from_report
    end

    def filtered_establishments_data_from_report
      full_data = @data_extractor.extract(:establishments_data)
      titles = full_data.first
      establishment_rows = full_data[1..]

      academy_establishments = Establishment.joins(:classes)
                                            .where(academy_code: selected_academy,
                                                   "classes.school_year_id": @report.school_year)
                                            .distinct
                                            .pluck(:uai)

      filtered_rows = establishment_rows.select do |row|
        uai = row[0]
        academy_establishments.include?(uai)
      end

      [titles, *filtered_rows]
    end

    def load_establishments_hash
      establishment_uais = @establishments_data[1..].map(&:first)
      Establishment.where(uai: establishment_uais).index_by(&:uai)
    end

    def calculate_academy_progressions
      return {} unless @comparison_report

      Academic::ReportsProgressionComparator.compare(@report, @comparison_report, selected_academy)
    end

    def calculate_global_progressions
      return {} unless @comparison_report

      Reports::GlobalProgressionComparator.compare(@report, @comparison_report)
    end

    def determine_comparison_report
      if params[:comparison_report_id].present?
        @comparable_reports.find_by(id: params[:comparison_report_id])
      else
        @comparable_reports.first
      end
    end

    def export_files
      Reports::CSVExporter.new(@report).csv_files.map do |filename, content|
        [StringIO.new(content), filename]
      end
    end

    def export_filename
      year = @report.school_year.start_year
      date = @report.created_at.strftime("%Y%m%d")
      "aplypro_rapport_#{@report.id}_annee-scol#{year}_date#{date}.zip"
    end
  end
end
