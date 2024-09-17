# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClassesFacade do
  subject(:facade) { described_class.new(Classe.all) }

  let(:classes) { create_list(:classe, 3) }

  describe "#nb_students_per_class" do
    before do
      classes.each do |classe|
        create_list(:schooling, 2, classe: classe)
      end
    end

    it "returns the correct number of students per class" do
      expect(facade.nb_students_per_class).to eq(classes.to_h { |c| [c.id, 2] })
    end
  end

  describe "#nb_attributive_decisions_per_class" do
    before do
      classes.each do |classe|
        create(:schooling, :with_attributive_decision, classe: classe)
        create(:schooling, classe: classe)
      end
    end

    it "returns the correct number of attributive decisions per class" do
      expect(facade.nb_attributive_decisions_per_class).to eq(classes.to_h { |c| [c.id, 1] })
    end
  end

  describe "#nb_ribs_per_class" do
    before do
      classes.each do |classe|
        create(:schooling, student: create(:student, :with_rib), classe: classe)
        create(:schooling, classe: classe)
      end
    end

    it "returns the correct number of RIBs per class" do
      expect(facade.nb_ribs_per_class).to eq(classes.to_h { |c| [c.id, 1] })
    end
  end

  describe "#nb_pfmps" do
    let(:classe) { classes.first }

    before do
      create(:pfmp).update(classe: classe)
      create(:pfmp, :completed).update(classe: classe)
      create(:pfmp, :validated).update(classe: classe)
    end

    it "returns the correct number of PFMPs for each state" do
      expect([facade.nb_pfmps(classe.id, :pending),
              facade.nb_pfmps(classe.id, :completed),
              facade.nb_pfmps(classe.id, :validated)]).to eq([1, 1, 1])
    end

    it "returns 0 for non-existent states" do
      expect(facade.nb_pfmps(classe.id, :non_existent)).to eq(0)
    end
  end
end
