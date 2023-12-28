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

Alors("le panneau {string} contient un compteur à {int} sur {int}") do |title, low, high|
  within(".gray-panel", text: title) do
    expect(page).to have_content("#{low} / #{high}")
  end
end

Alors("l'indicateur de PFMP {string} affiche {int}") do |status, count|
  within("div[aria-label=\"#{status}\"]") do
    expect(page).to have_content(count)
  end
end
