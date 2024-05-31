# frozen_string_literal: true

require "rails_helper"

describe StudentsApi do
  describe ".api_for" do
    subject(:api) { described_class.api_for(provider) }

    %w[sygne fregata].each do |provider|
      context "when asked for a #{provider.upcase} API" do
        let(:provider) { provider }

        it { is_expected.to respond_to(:fetch_resource) }
      end
    end

    context "when asked for an unknown provider" do
      let(:provider) { "foobar" }

      it "raises an error" do
        expect { api }.to raise_error(/no matching API/)
      end
    end
  end
end
