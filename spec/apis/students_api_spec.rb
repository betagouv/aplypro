# frozen_string_literal: true

require "rails_helper"

describe StudentsApi do
  describe ".api_for" do
    subject(:api_for) { described_class.api_for(provider, "123") }

    %w[sygne fregata].each do |provider|
      context "when asked for a #{provider.upcase} API" do
        let(:provider) { provider }

        it { is_expected.to be_a "StudentsApi::#{provider.capitalize}::Api".constantize }
      end
    end

    context "when asked for an unknown provider" do
      let(:provider) { "foobar" }

      it "raises an error" do
        expect { api_for }.to raise_error(/no matching API/)
      end
    end
  end
end
