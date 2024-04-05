# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "an ASP-friendly date attribute" do |attribute:|
  it "formats the date correctly" do
    date = Date.new(2024, 10, 23)

    model.send "#{attribute}=", date

    expect(model.send(attribute).to_s).to eq "23/10/2024"
  end
end

RSpec.shared_examples "a limited string attribute" do |attribute:, length:|
  it "chops the '#{attribute}' attribute to #{length} characters" do
    model.send "#{attribute}=", Faker::Alphanumeric.alpha(number: length + 1)

    expect(model.send(attribute).to_s).to have(length).characters
  end
end
