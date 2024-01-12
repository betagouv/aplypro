# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersonnePhysique do
  describe ".from_student" do
    subject(:model) { described_class.from_student(student) }

    let(:student) { create(:student, :male, :with_address_info, :with_birthplace_info, first_name: "Marie") }

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
end
