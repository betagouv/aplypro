# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClassesFacade do
  subject(:facade) { described_class.new(Classe.all, establishment) }

  let(:classes) { create_list(:classe, 3, establishment: establishment) }
  let(:establishment) { create(:establishment) }

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
