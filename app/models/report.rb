# frozen_string_literal: true

class Report < ApplicationRecord
  GENERIC_DATA_KEYS = ["DA", "Coord. bancaires", "PFMPs validées", "Données élèves", "Mt. prêt envoi",
                       "Mt. annuel total", "Scolarités", "Toutes PFMPs", "Dem. envoyées", "Dem. intégrées"].freeze

  belongs_to :school_year

  validates :data, presence: true
  validates :created_at, presence: true, uniqueness: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_school_year, ->(school_year) { where(school_year: school_year) }

  def self.latest
    ordered.first
  end

  def previous_report
    self.class.for_school_year(school_year).where(created_at: ...created_at).ordered.first
  end

  def next_report
    self.class.for_school_year(school_year).where("created_at > ?", created_at).order(:created_at).first
  end

  def self.create_for_date(date = Time.current)
    current_school_year = SchoolYear.current
    return if exists?(created_at: date.all_day, school_year: current_school_year)

    stats_data = generate_stats_data
    create!(
      data: stats_data,
      created_at: date,
      school_year: current_school_year
    )
  end

  class << self
    private

    def generate_stats_data
      current_school_year = SchoolYear.current.start_year
      stats = Stats::Main.new(current_school_year)
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
