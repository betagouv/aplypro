# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a limited string attribute" do |attribute:, length:|
  it "chops the '#{attribute}' attribute to #{length} characters" do
    model.send "#{attribute}=", Faker::Alphanumeric.alpha(number: length + 1)

    expect(model.send(attribute).to_s).to have(length).characters
  end
end
