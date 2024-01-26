# frozen_string_literal: true

require "rails_helper"

describe ASP::StudentFileEligibilityChecker do
  subject(:checker) { described_class.new(student.reload) }

  let(:student) { create(:student, :with_all_asp_info) }

  context "with the right factory" do
    it { is_expected.to be_ready }
  end

  context "when the student is missing a rib" do
    before { student.rib.destroy }

    it { is_expected.not_to be_ready }
  end

  context "when the student is missing birthplace info" do
    before { student.update!(birthplace_country_insee_code: nil) }

    it { is_expected.not_to be_ready }
  end

  context "when the student is missing some address info" do
    before { student.update!(address_country_code: nil) }

    it { is_expected.not_to be_ready }
  end

  # like this matters :face_with_rolling_eyes:
  context "when the student's sex is unknown" do
    before { student.update!(biological_sex: :unknown) }

    it { is_expected.not_to be_ready }
  end
end
