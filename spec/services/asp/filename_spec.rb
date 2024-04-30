# frozen_string_literal: true

require "rails_helper"

describe ASP::Filename do
  subject(:filename) { described_class.new(str) }

  describe "#kind" do
    subject { filename.kind }

    %i[rejects integrations payments].each do |type|
      context "when the filename looks like a #{type} file" do
        let(:str) { build(:asp_filename, type) }

        it { is_expected.to eq type }
      end
    end
  end

  describe "original_filename" do
    subject { filename.original_filename }

    context "when the file is payments file" do
      let(:str) { build(:asp_filename, :payments) }

      it { is_expected.to be_nil }
    end

    %i[rejects integrations].each do |type|
      context "when the file is #{type} file" do
        let(:str) { build(:asp_filename, type, identifier: "some identifier") }

        it { is_expected.to eq "some identifier.xml" }
      end
    end
  end
end
