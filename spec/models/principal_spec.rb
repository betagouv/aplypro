# frozen_string_literal: true

require "rails_helper"

RSpec.describe Principal do
  it "has a valid factory" do
    expect(build(:principal)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
  end

  describe "validations" do
    %w[uid name email provider token secret email].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end

  describe ".from_fim" do
    before do
      allow_any_instance_of(Establishment).to receive(:queue_refresh)
      create(:establishment, uai: "E020202K")
    end

    let(:data) { JSON.parse(File.read("spec/models/data/fim.json")) }
    let(:principal) { described_class.from_fim(data) }

    {
      name: "Ens2D05 Pourtest5",
      email: "ens2d05.pourtest5@ac-bordeaux.fr",
      establishment_id: "E020202K"
    }.each do |attr, value|
      it "maps the `#{attr} attribute" do
        expect(principal[attr]).to eq value
      end
    end
  end
end
