# frozen_string_literal: true

Alors("le bandeau informatif contient {string}") do |text|
  expect(page.find(".etab-banner")).to have_content(text).or(have_button(text))
end
