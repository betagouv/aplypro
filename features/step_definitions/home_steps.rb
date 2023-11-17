# frozen_string_literal: true

Alors("le panneau {string} contient {string}") do |title, counter_string|
  expect(page.find(".gray-panel", text: title)).to have_content(counter_string)
end

Alors("le panneau {string} ne contient pas {string}") do |title, counter_string|
  expect(page.find(".gray-panel", text: title)).not_to have_content(counter_string)
end

Quand("l'établissement {string} fait parti des établissments soutenus directement") do |uai|
  ENV.update("APLYPRO_DIRECT_SUPPORT_UAIS" => uai)
end
