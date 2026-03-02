# frozen_string_literal: true

require "rails_helper"

RSpec.shared_context "when there is data for global stats" do
  before do
    mef = create(:mef, daily_rate: 1, yearly_cap: 100)
    establishment = create(:establishment)
    classe = create(:classe, mef: mef, establishment: establishment)

    create_list(:schooling, 3, classe: classe) do |schooling|
      create(:pfmp, schooling: schooling, day_count: 5)
    end

    create_list(:student, 2, :asp_ready, establishment: establishment) do |student|
      schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
      pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
      create(:asp_payment_request, :sent, pfmp: pfmp)
    end
  end
end

RSpec.shared_context "when there is data for stats per bops" do
  before do
    Mef.ministries.each_key.with_index do |ministry, index|
      mef = create(:mef, ministry: ministry, daily_rate: 1, yearly_cap: 100)
      establishment = create(:establishment)
      classe = create(:classe, mef: mef, establishment: establishment)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
        create(:asp_payment_request, :integrated, pfmp: pfmp)
      end
    end

    private_establishment = create(:establishment, :private)
    menj_mef = create(:mef, ministry: :menj, daily_rate: 1, yearly_cap: 100)
    private_classe = create(:classe, establishment: private_establishment, mef: menj_mef)

    create_list(:schooling, 1, classe: private_classe) do |schooling|
      create(:pfmp, schooling: schooling, day_count: 5)
    end

    create_list(:student, 4, :asp_ready, establishment: private_establishment) do |student|
      schooling = create(:schooling, :with_attributive_decision, classe: private_classe, student: student)
      pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
      create(:asp_payment_request, :integrated, pfmp: pfmp)
    end
  end
end

RSpec.shared_context "when there is data for stats per MENJ academies" do
  before do
    mef = create(:mef, ministry: :menj, daily_rate: 1, yearly_cap: 100)

    %w[Bordeaux Paris Montpellier].each.with_index do |academy_label, index|
      establishment = create(:establishment, academy_label: academy_label)
      classe = create(:classe, mef: mef, establishment: establishment)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end

RSpec.shared_context "when there is also data for a non MENJ academy" do
  before do
    masa_mef = create(:mef, ministry: :masa)
    establishment = create(:establishment, academy_label: "Bordeaux")
    classe = create(:classe, mef: masa_mef, establishment: establishment)
    create_list(:schooling, 3, classe: classe)
    create_list(:schooling, 1, :with_attributive_decision, classe: classe)
  end
end

RSpec.shared_context "when there is data for stats per establishments" do
  before do
    %w[0000000A 0000000C 0000000B].each.with_index do |uai, index|
      establishment = create(:establishment, uai: uai, name: uai)
      mef = create(:mef, daily_rate: 1, yearly_cap: 100)
      classe = create(:classe, establishment: establishment, mef: mef)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end

RSpec.shared_context "when there is data for payable stats globally" do
  before do
    mef = create(:mef, daily_rate: 1, yearly_cap: 100)
    establishment = create(:establishment)
    classe = create(:classe, mef: mef, establishment: establishment)
    school_year_range = establishment.school_year_range(classe.school_year.start_year)

    create_list(:student, 2, :asp_ready, establishment: establishment) do |student|
      schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
      schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
      create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                start_date: 1.month.ago, end_date: 1.week.ago)
    end
  end
end

RSpec.shared_context "when there is data for payable stats per bops" do
  before do
    Mef.ministries.each_key.with_index do |ministry, index|
      mef = create(:mef, ministry: ministry, daily_rate: 1, yearly_cap: 100)
      establishment = create(:establishment)
      classe = create(:classe, mef: mef, establishment: establishment)
      school_year_range = establishment.school_year_range(classe.school_year.start_year)

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
        create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                  start_date: 1.month.ago, end_date: 1.week.ago)
      end
    end

    private_establishment = create(:establishment, :private)
    menj_mef = create(:mef, ministry: :menj, daily_rate: 1, yearly_cap: 100)
    private_classe = create(:classe, establishment: private_establishment, mef: menj_mef)
    private_school_year_range = private_establishment.school_year_range(private_classe.school_year.start_year)

    create_list(:student, 4, :asp_ready, establishment: private_establishment) do |student|
      schooling = create(:schooling, :with_attributive_decision, classe: private_classe, student: student)
      schooling.update!(start_date: private_school_year_range.first, end_date: private_school_year_range.last)
      create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                start_date: 1.month.ago, end_date: 1.week.ago)
    end
  end
end

RSpec.shared_context "when there is data for payable stats per MENJ academies" do
  before do
    mef = create(:mef, ministry: :menj, daily_rate: 1, yearly_cap: 100)

    %w[Bordeaux Paris Montpellier].each.with_index do |academy_label, index|
      establishment = create(:establishment, academy_label: academy_label)
      classe = create(:classe, mef: mef, establishment: establishment)
      school_year_range = establishment.school_year_range(classe.school_year.start_year)

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                         start_date: 1.month.ago, end_date: 1.week.ago)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end

RSpec.shared_context "when there is data for payable stats per establishments" do
  before do
    %w[0000000A 0000000C 0000000B].each.with_index do |uai, index|
      establishment = create(:establishment, uai: uai, name: uai)
      mef = create(:mef, daily_rate: 1, yearly_cap: 100)
      classe = create(:classe, establishment: establishment, mef: mef)
      school_year_range = establishment.school_year_range(classe.school_year.start_year)

      create_list(:student, index + 1, :asp_ready, establishment: establishment) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        schooling.update!(start_date: school_year_range.first, end_date: school_year_range.last)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5,
                                         start_date: 1.month.ago, end_date: 1.week.ago)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end

RSpec.shared_context "with the initialization of OMOGEN connection" do
  before do
    stub_request(:post, "#{ENV.fetch('APLYPRO_OMOGEN_TOKEN_URL')}/token")
      .with(
        body: {
          grant_type: ENV.fetch("APLYPRO_OMOGEN_GRANT_TYPE"),
          client_id: ENV.fetch("APLYPRO_OMOGEN_CLIENT_ID"),
          client_secret: ENV.fetch("APLYPRO_OMOGEN_CLIENT_SECRET")
        }
      )
      .to_return(
        status: 200,
        body: { access_token: "fake-token", expires_in: 300 }.to_json
      )
  end
end
