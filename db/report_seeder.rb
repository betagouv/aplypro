# frozen_string_literal: true

require "./spec/support/attributive_decision_helpers"

class ReportSeeder
  def self.seed
    raise "ReportSeeder cannot be run in production!" if Rails.env.production?

    load_asp_factories

    cleanup_existing_data
    Report.destroy_all

    school_years = SchoolYear.order(start_year: :desc).limit(3)

    school_years.each_with_index do |school_year, year_index|
      dates = [
        (5 + (year_index * 52)).weeks.ago,
        (3 + (year_index * 52)).weeks.ago
      ]

      dates.each_with_index do |date, report_index|
        seed_offset = (year_index * 2) + report_index

        ApplicationRecord.transaction do
          create_fake_academy_data(school_year, seed_offset)
        end

        report_data = generate_bogus_data(school_year.start_year, seed_offset)
        Report.create!(
          data: report_data,
          created_at: date,
          school_year: school_year
        )
      end
    end
  end

  def self.load_asp_factories
    FactoryBot.build(:asp_integration)
  rescue ArgumentError, KeyError => e
    raise unless e.message.include?("Factory not registered") || e.message.include?("asp")

    load "mock/factories/asp.rb"
  end

  def self.cleanup_existing_data
    test_establishments = Establishment.where("uai LIKE 'RS%'")
    test_establishment_ids = test_establishments.pluck(:id)
    classes = Classe.where(establishment: test_establishments)
    schoolings = Schooling.where(classe: classes)
    student_ids = schoolings.pluck(:student_id).uniq
    pfmp_ids = Pfmp.where(schooling: schoolings).pluck(:id)

    PfmpTransition.where(pfmp_id: pfmp_ids).delete_all
    ASP::PaymentRequest.where(pfmp_id: pfmp_ids).destroy_all
    Pfmp.where(id: pfmp_ids).delete_all
    Rib.where(student_id: student_ids).delete_all
    schoolings.delete_all
    Student.where(id: student_ids).delete_all
    classes.delete_all
    EstablishmentUserRole.where(establishment_id: test_establishment_ids).delete_all
    test_establishments.delete_all
  end

  def self.create_fake_academy_data(_school_year, seed_offset)
    academy_code = "06"
    academy_label = "Clermont-Ferrand"

    ready_count = 3 + seed_offset
    paid_count = 1 + seed_offset

    ready_count.times do
      payment_request = FactoryBot.create(:asp_payment_request, :ready)
      establishment = payment_request.pfmp.schooling.classe.establishment
      establishment.update!(
        academy_code: academy_code,
        academy_label: academy_label,
        uai: "RS#{rand(10_000..99_999)}"
      )
    end

    paid_count.times do
      payment_request = FactoryBot.create(:asp_payment_request, :paid)
      establishment = payment_request.pfmp.schooling.classe.establishment
      establishment.update!(
        academy_code: academy_code,
        academy_label: academy_label,
        uai: "RS#{rand(10_000..99_999)}"
      )
    end
  end

  def self.generate_bogus_data(start_year, seed_offset = 0)
    stats = Stats::Main.new(start_year)
    indicators_titles = stats.indicators_titles
    academies = Establishment.distinct.pluck(:academy_label).compact.uniq.sort

    establishments = []

    Establishment.where(academy_code: "06").where.not("uai LIKE 'RS%'").find_each do |establishment|
      indicator_values = stats.indicators.map do |indicator|
        calculate_real_indicator_value(indicator, establishment, start_year, seed_offset)
      end

      establishments << [
        establishment.uai,
        establishment.name,
        establishment.ministry,
        establishment.academy_label,
        establishment.private_contract_type_code == 99 ? "Public" : "Privé",
        *indicator_values
      ]
    end

    Establishment.where("uai LIKE 'RS%'").find_each do |establishment|
      indicator_values = stats.indicators.map do |indicator|
        calculate_real_indicator_value(indicator, establishment, start_year, seed_offset)
      end

      establishments << [
        establishment.uai,
        establishment.name,
        establishment.ministry,
        establishment.academy_label,
        establishment.private_contract_type_code == 99 ? "Public" : "Privé",
        *indicator_values
      ]
    end

    bops_data = [
      ["BOP", *indicators_titles],
      ["ENPU", *generate_bop_row(stats, seed_offset)],
      ["ENPR", *generate_bop_row(stats, seed_offset)],
      ["MASA", *generate_bop_row(stats, seed_offset)],
      ["MER", *generate_bop_row(stats, seed_offset)]
    ]

    menj_academies_data = [
      ["Académie", *indicators_titles],
      *academies.map { |academy| [academy, *generate_academy_row(stats, seed_offset)] }
    ]

    global_data = [
      indicators_titles,
      stats.indicators.map do |indicator|
        generate_global_value(indicator, seed_offset)
      end
    ]

    {
      global_data: global_data,
      bops_data: bops_data,
      menj_academies_data: menj_academies_data,
      establishments_data: [
        ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public", *indicators_titles], *establishments
      ]
    }
  end

  def self.generate_bop_row(stats, seed_offset)
    stats.indicators.map do |indicator|
      generate_bop_value(indicator, seed_offset)
    end
  end

  def self.generate_academy_row(stats, seed_offset)
    stats.indicators.map do |indicator|
      generate_academy_value(indicator, seed_offset)
    end
  end

  def self.generate_indicator_value(indicator, seed_offset)
    variance = (seed_offset * 5) + rand(-10..10)
    case indicator
    when Stats::Ratio
      (rand(50..100) + variance).clamp(30, 100) / 100.0
    when Stats::Sum
      rand(10_000..500_000) + (seed_offset * 50_000) + rand(-20_000..20_000)
    when Stats::Count
      rand(50..300) + (seed_offset * 20) + rand(-15..15)
    else
      (rand(50..100) + variance).clamp(30, 100) / 100.0
    end
  end

  def self.generate_global_value(indicator, seed_offset)
    variance = (seed_offset * 3) + rand(-5..5)
    case indicator
    when Stats::Ratio
      (rand(70..95) + variance).clamp(50, 100) / 100.0
    when Stats::Sum
      rand(5_000_000..20_000_000) + (seed_offset * 1_000_000) + rand(-500_000..500_000)
    when Stats::Count
      rand(5000..15_000) + (seed_offset * 500) + rand(-300..300)
    else
      (rand(70..95) + variance).clamp(50, 100) / 100.0
    end
  end

  def self.generate_bop_value(indicator, seed_offset)
    variance = (seed_offset * 4) + rand(-8..8)
    case indicator
    when Stats::Ratio
      (rand(60..95) + variance).clamp(40, 100) / 100.0
    when Stats::Sum
      rand(1_000_000..8_000_000) + (seed_offset * 400_000) + rand(-200_000..200_000)
    when Stats::Count
      rand(1000..5000) + (seed_offset * 200) + rand(-100..100)
    else
      (rand(60..95) + variance).clamp(40, 100) / 100.0
    end
  end

  def self.generate_academy_value(indicator, seed_offset)
    variance = (seed_offset * 5) + rand(-10..10)
    case indicator
    when Stats::Ratio
      (rand(55..98) + variance).clamp(40, 100) / 100.0
    when Stats::Sum
      rand(200_000..2_000_000) + (seed_offset * 100_000) + rand(-50_000..50_000)
    when Stats::Count
      rand(200..1500) + (seed_offset * 50) + rand(-30..30)
    else
      (rand(55..98) + variance).clamp(40, 100) / 100.0
    end
  end

  def self.calculate_real_indicator_value(indicator, establishment, start_year, seed_offset = 0)
    school_year = SchoolYear.find_by(start_year: start_year)
    return 0 unless school_year

    case indicator.class.name
    when "Stats::Indicator::Ratio::Ribs"
      establishment.ribs.count
    when "Stats::Indicator::Ratio::PfmpsValidated"
      finished_pfmps = establishment.pfmps.joins(schooling: { classe: :school_year })
                                    .where(classes: { school_year_id: school_year.id })
                                    .finished
      validated = finished_pfmps.in_state(:validated).count
      total = finished_pfmps.count
      total.zero? ? 0.0 : validated.to_f / total
    when "Stats::Indicator::Ratio::StudentsData"
      establishment.students.joins(:schoolings).where(schoolings: { classe_id: establishment.classes.where(school_year: school_year) }).distinct.count
    when "Stats::Indicator::Sum::Yearly"
      establishment.schoolings.joins(classe: :mef)
                   .where(classes: { school_year_id: school_year.id })
                   .merge(Mef.with_wages)
                   .sum("wages.yearly_cap")
    when "Stats::Indicator::Count::Schoolings"
      establishment.schoolings.joins(:classe).where(classes: { school_year_id: school_year.id }).count
    when "Stats::Indicator::Count::Pfmps"
      establishment.pfmps.joins(schooling: { classe: :school_year }).where(classes: { school_year_id: school_year.id }).count
    when "Stats::Indicator::Ratio::PfmpPaidPayable"
      pfmps = establishment.pfmps.joins(schooling: { classe: :school_year })
                           .where(classes: { school_year_id: school_year.id })
      paid_count = pfmps.joins(:payment_requests).merge(ASP::PaymentRequest.in_state(:paid)).distinct.count
      payable_count = pfmps.in_state(:validated).count
      payable_count.zero? ? 0.0 : paid_count.to_f / payable_count
    else
      generate_indicator_value(indicator, seed_offset)
    end
  end
end
