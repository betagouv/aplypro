# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student do
  it "has a valid factory" do
    expect(build(:student)).to be_valid
  end

  it { is_expected.to belong_to(:classe) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:ine) }

  describe ".from_sygne_hash" do
    let!(:attrs) do
      {
        "ine" => "123123",
        "prenom" => "Jean",
        "nom" => "Tonic"
      }
    end

    let(:student) { described_class.from_sygne_hash(attrs) }

    Student::SYGNE_MAPPING.each do |attr, col|
      it "parses the `#{attr}` attribute into the `#{col}` column" do
        expect(student[col]).to eq attrs[attr]
      end
    end
  end
end
