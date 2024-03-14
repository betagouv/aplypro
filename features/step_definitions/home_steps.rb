# frozen_string_literal: true

Alors("le panneau {string} contient {string}") do |title, text|
  expect(page.find(".gray-panel", text: title)).to have_content(text).or(have_button(text))
end

Alors("le panneau {string} ne contient pas {string}") do |title, text|
  expect(page.find(".gray-panel", text: title)).to have_no_content(text)
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

Alors("l'indicateur de demandes de paiements {string} affiche {int}") do |status, count|
  within("div[aria-label=\"#{status}\"]") do
    expect(page).to have_content(count)
  end
end

Alors("l'indicateur de demandes de paiements {string} n'est pas affiché") do |status|
  expect(page).to have_no_css("div[aria-label=\"#{status}\"]")
end

Lorsque("je suis responsable légal et que je génère les décisions d'attribution manquantes") do
  steps %(
    Lorsque je coche la case de responsable légal
    Et que je clique sur "Éditer"
  )
end

CONFIRM_DIRECTOR_LABEL = "Je confirme que je suis le responsable légal de l'établissement"

Lorsque("je coche la case de responsable légal") do
  steps %(
    Lorsque je coche "#{CONFIRM_DIRECTOR_LABEL}"
  )
end

Lorsque("je décoche la case de responsable légal") do
  steps %(
    Lorsque je décoche "#{CONFIRM_DIRECTOR_LABEL}"
  )
end
