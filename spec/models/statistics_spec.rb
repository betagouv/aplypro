# frozen_string_literal: true

require "rails_helper"

RSpec.describe Statistics do
  subject(:statistics) { build(:statistics) }

  it { is_expected.to belong_to(:school_year).class_name("SchoolYear") }

  describe "scopes" do
    let(:global) { create(:statistics, :global) }
    let(:bop) { create(:statistics, :bop) }
    let(:establishment) { create(:statistics, :establishment) }
    let(:academy) { create(:statistics, :academy) }

    describe ".global" do
      it { expect(described_class.global).to contain_exactly(global) }
    end

    describe ".bop" do
      it { expect(described_class.global).to contain_exactly(bop) }
    end

    describe ".establishment" do
      it { expect(described_class.global).to contain_exactly(establishment) }
    end

    describe ".academy" do
      it { expect(described_class.global).to contain_exactly(academy) }
    end
  end
end
