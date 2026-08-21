# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActionCable::SubscriptionAdapter do
  it "loads the Redis adapter successfully" do
    expect do
      require "action_cable/subscription_adapter/redis"
    end.not_to raise_error
  end
end
