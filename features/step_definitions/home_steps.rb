# frozen_string_literal: true

Alors("le panel de décision d'attribution contient {string}") do |content|
  expect(page).to have_css("#attributive_decision_panel", text: content)
end
