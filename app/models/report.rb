# frozen_string_literal: true

class Report < ApplicationRecord
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
        global_data: stats.global_data,
        bops_data: stats.bops_data,
        menj_academies_data: stats.menj_academies_data,
        establishments_data: stats.establishments_data
      }
    end
  end
end
