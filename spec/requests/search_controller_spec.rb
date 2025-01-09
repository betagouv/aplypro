# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchController do
  describe "#unify" do
    let(:controller) { described_class.new }

    it "returns transformed string" do
      expect(controller.send(:unify, "Jüãn-Frânçois Mîchäèl")).to eq "JUAN FRANCOIS MICHAEL"
    end
  end
end
