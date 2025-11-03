# frozen_string_literal: true

class Report < ApplicationRecord
  GENERIC_DATA_KEYS = ["DA", "Coord. bancaires", "PFMPs validées", "Données élèves", "Mt. prêt envoi",
                       "Mt. annuel total", "Scolarités", "Toutes PFMPs", "Dem. envoyées", "Dem. intégrées",
                       "Dem. payées", "Mt. payé", "Ratio PFMPs payées/payables"].freeze

  ReportDataSchema = Dry::Schema.JSON do
    required(:global_data).value(:array, min_size?: 2) do
      first.value(eql?: GENERIC_DATA_KEYS)
      each.value(:array, size?: GENERIC_DATA_KEYS.length)
    end

    required(:bops_data).value(:array, min_size?: 2) do
      first.value(eql?: ["BOP"] + GENERIC_DATA_KEYS)
      each.value(:array, size?: 1 + GENERIC_DATA_KEYS.length)
    end

    required(:menj_academies_data).value(:array, min_size?: 2) do
      first.value(eql?: ["Académie"] + GENERIC_DATA_KEYS)
      each.value(:array, size?: 1 + GENERIC_DATA_KEYS.length)
    end

    establishment_keys = ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public"]
    required(:establishments_data).value(:array, min_size?: 2) do
      first.value(eql?: establishment_keys + GENERIC_DATA_KEYS)
      each.value(:array, size?: 5 + GENERIC_DATA_KEYS.length)
    end
  end

  attr_accessor :skip_schema_validation

  belongs_to :school_year

  validates :data, presence: true
  validates :created_at, presence: true, uniqueness: { scope: :school_year_id }
  validate :validate_report_structure, unless: -> { Rails.env.test? && skip_schema_validation }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_school_year, ->(school_year) { where(school_year: school_year) }

  def previous_report
    self.class.for_school_year(school_year).where(created_at: ...created_at).ordered.first
  end

  def next_report
    self.class.for_school_year(school_year).where("created_at > ?", created_at).order(:created_at).first
  end

  def validate_report_structure
    return if data.blank?

    result = ReportDataSchema.call(data)
    result.errors.messages.each { |msg| errors.add(:data, msg.text) } if result.failure?
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
        bops_data: serialize_data(stats.bops_data, ["BOP"]),
        menj_academies_data: serialize_data(stats.menj_academies_data, ["Académie"]),
        establishments_data: serialize_data(stats.establishments_data, ["UAI", "Nom de l'établissement",
                                                                        "Ministère", "Académie", "Privé/Public"])
      }
    end

    def serialize_data(data, specific_keys = [])
      keys = specific_keys + GENERIC_DATA_KEYS
      rows = data.presence || [{}]

      [
        keys,
        *rows.map do |row|
          keys.map { |k| row[k.to_sym].presence }
        end
      ]
    end
  end
end
