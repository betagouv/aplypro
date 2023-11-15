# frozen_string_literal: true

Alors("le panneau {string} contient un compteur à {string}") do |title, counter_string|
  expect(page.find(".gray-panel", text: title)).to have_content(counter_string)
end
