# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Action Cable Redis adapter" do
  it "loads successfully" do
    expect do
      require "action_cable/subscription_adapter/redis"
    end.not_to raise_error
  end
end
