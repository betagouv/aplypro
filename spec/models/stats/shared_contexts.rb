# frozen_string_literal: true

require "rails_helper"

RSpec.shared_context "when we are in October 2024" do
  before do
    Timecop.safe_mode = false
    Timecop.freeze(Date.new(2024, 10, 1))
  end

  after do
    Timecop.return
  end
end

RSpec.shared_context "when there is data for global stats" do
  include_context "when we are in October 2024"

  before do
    mef = create(:mef, daily_rate: 1, yearly_cap: 100)
    classe = create(:classe, mef: mef)

    create_list(:schooling, 3, classe: classe) do |schooling|
      create(:pfmp, schooling: schooling, day_count: 5)
    end

    create_list(:student, 2, :asp_ready) do |student|
      schooling = create(:schooling, :with_attributive_decision, :student, classe: classe, student: student)
      pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
      create(:asp_payment_request, :sent, pfmp: pfmp)
    end
  end
end

RSpec.shared_context "when there is data for stats per bops" do
  include_context "when we are in October 2024"

  before do
    Mef.ministries.each_key.with_index do |ministry, index|
      mef = create(:mef, ministry: ministry, daily_rate: 1, yearly_cap: 100)
      classe = create(:classe, mef: mef)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready) do |student|
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

    create_list(:student, 4, :asp_ready) do |student|
      schooling = create(:schooling, :with_attributive_decision, classe: private_classe, student: student)
      pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
      create(:asp_payment_request, :integrated, pfmp: pfmp)
    end
  end
end

RSpec.shared_context "when there is data for stats per MENJ academies" do
  include_context "when we are in October 2024"

  before do
    mef = create(:mef, ministry: :menj, daily_rate: 1, yearly_cap: 100)

    %w[Bordeaux Paris Montpellier].each.with_index do |academy_label, index|
      establishment = create(:establishment, academy_label: academy_label)
      classe = create(:classe, mef: mef, establishment: establishment)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end

RSpec.shared_context "when there is also data for a non MENJ academy" do
  include_context "when we are in October 2024"

  before do
    masa_mef = create(:mef, ministry: :masa)
    establishment = create(:establishment, academy_label: "Bordeaux")
    classe = create(:classe, mef: masa_mef, establishment: establishment)
    create_list(:schooling, 3, classe: classe)
    create_list(:schooling, 1, :with_attributive_decision, classe: classe)
  end
end

RSpec.shared_context "when there is data for stats per establishments" do
  include_context "when we are in October 2024"

  before do
    %w[etab1 etab3 etab2].each.with_index do |uai, index|
      establishment = create(:establishment, uai: uai, name: uai)
      mef = create(:mef, daily_rate: 1, yearly_cap: 100)
      classe = create(:classe, establishment: establishment, mef: mef)

      create_list(:schooling, 3, classe: classe) do |schooling|
        create(:pfmp, schooling: schooling, day_count: 5)
      end

      create_list(:student, index + 1, :asp_ready) do |student|
        schooling = create(:schooling, :with_attributive_decision, classe: classe, student: student)
        pfmp = create(:pfmp, :validated, schooling: schooling, day_count: 5)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end
    end
  end
end
