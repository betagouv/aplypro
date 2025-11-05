# frozen_string_literal: true

class Report < ApplicationRecord
  include ReportValidation

  HEADERS = %i[
    yearly_sum
    schoolings_count
    attributive_decisions_count
    attributive_decisions_ratio
    students_count
    ribs_count
    ribs_ratio
    students_data_count
    students_data_ratio
    pfmps_count
    pfmps_validated_count
    pfmps_validated_sum
    pfmps_completed_count
    pfmps_completed_sum
    pfmps_incompleted_count
    pfmps_incompleted_sum
    payment_requests_paid_count
    payment_requests_paid_sum
    payment_requests_recovery_sum
    students_paid_count
    students_paid_ratio
    pfmps_paid_count
    pfmps_payable_count
    pfmps_paid_payable_ratio
    pfmps_extended_count
    pfmps_extended_sum
  ].freeze

  ReportDataSchema = Dry::Schema.JSON do
    required(:global_data).value(:array, size?: 2).each(:array)

    required(:bops_data).value(:array, min_size?: 2).each(:array)

    required(:menj_academies_data).value(:array, min_size?: 2).each(:array)

    required(:establishments_data).value(:array, min_size?: 2).each(:array)
  end

  attr_accessor :skip_schema_validation

  belongs_to :school_year

  validates :data, presence: true
  validates :created_at, presence: true, uniqueness: { scope: :school_year_id }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_school_year, ->(school_year) { where(school_year: school_year) }

  def previous_report
    self.class.for_school_year(school_year).where(created_at: ...created_at).ordered.first
  end

  def next_report
    self.class.for_school_year(school_year).where("created_at > ?", created_at).order(:created_at).first
  end

  class << self
    def latest
      ordered.first
    end

    def create_for_school_year(school_year = SchoolYear.current, date = Time.current)
      return if exists?(created_at: date.all_day, school_year:)

      stats_data = generate_stats_data(school_year)

      create!(data: stats_data, created_at: date, school_year:)
    end

    private

    def generate_stats_data(school_year)
      stats = Stats::Main.new(school_year.start_year)
      {
        global_data: serialize_data(stats.global_data),
        bops_data: serialize_data(stats.bops_data, %i[bop]),
        menj_academies_data: serialize_data(stats.menj_academies_data, %i[academy]),
        establishments_data: serialize_data(stats.establishments_data,
                                            %i[uai establishment_name ministry academy private_or_public])
      }
    end

    # NOTE: serialize from hash like human readable structure to array like for storage
    def serialize_data(data, specific_keys = [])
      keys = specific_keys + HEADERS
      rows = data.presence || [{}]

      [
        keys,
        *rows.map do |row|
          keys.map { |k| row[k].presence }
        end
      ]
    end
  end
end
