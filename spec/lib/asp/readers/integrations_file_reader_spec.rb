# frozen_string_literal: true

require "rails_helper"

describe ASP::Readers::IntegrationsFileReader do
  subject(:reader) { described_class.new(data) }

  let(:student) { create(:student) }

  let(:data) do
    """
Numero enregistrement;idIndDoss;idIndTiers;idDoss;numAdmDoss;idPretaDoss;numAdmPrestaDoss;idIndPrestaDoss
#{student.id};700056261;;700086362;ENPUPLF1POP31X20230;700085962;ENPUPLF1POP31X20230;700056261
"""
  end

  it "updates an existing individual request" do
    expect { reader.process! }.to change { student.reload.asp_individual_reference }.from(nil).to("700056261")
  end
end
