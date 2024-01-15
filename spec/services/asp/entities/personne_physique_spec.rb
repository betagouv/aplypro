# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersonnePhysique do
  let(:student) { create(:student, :female, :with_address_info, :with_birthplace_info, first_name: "Marie") }

  it_behaves_like "an ASP student mapping entity"

  describe "to_xml" do
    subject(:document) { Nokogiri::XML(described_class.from_student(student).to_xml) }

    it "can generate some XML" do
      expect(document.to_s).not_to be_empty
    end

    specify "prenom" do
      expect(document.at("persphysique/prenom")).to have_attributes(text: "Marie")
    end
  end
end
