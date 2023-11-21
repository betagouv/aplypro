# frozen_string_literal: true

Quand("je me rends sur la page d'accueil") do
  visit "/"
end

Quand("print the page") do
  log page.body
end

Quand("je clique sur {string}") do |label|
  click_link_or_button label # rubocop:disable Capybara/ClickLinkOrButtonStyle
end

Alors("la page contient {string}") do |content|
  expect(page).to have_content(content)
end

Alors("la page ne contient pas {string}") do |content|
  expect(page).not_to have_content(content)
end

Alors("la page contient {string} dans la rangée {string} du tableau {string}") do |content, row, caption|
  expect(page).to have_table(caption, with_rows: [row, content])
end

Alors("le tableau {string} contient") do |caption, table|
  expect(page).to have_table(caption, with_rows: table.rows)
end

Alors("le titre de la page contient {string}") do |text|
  expect(page.title.gsub("  ", " ")).to include text
end

Alors("il y a un titre de premier niveau contenant {string}") do |text|
  # le titre est soit le premier h1 ou la légende du premier tableau
  element = page.all("h1").first || page.all("table caption").first

  expect(element.text).to include(text)
end

Alors("la page est titrée {string}") do |text|
  steps %(
    Alors il y a un titre de premier niveau contenant "#{text}"
    Et le titre de la page contient "#{text}"
  )
end

Quand("je remplis {string} avec {string}") do |label, value|
  fill_in label, with: value
end

Quand("je clique sur {string} dans la rangée {string}") do |link, row|
  within("tr", text: row) do
    click_link(link)
  end
end

Quand("je sélectionne {string} pour {string}") do |option, name|
  select option, from: name
end

Quand("je choisis {string}") do |option|
  choose option
end

Alors("je peux voir dans le tableau {string}") do |caption, table|
  expect(page).to have_table(caption, with_rows: table.rows)
end

Alors("debug") do
  debugger # rubocop:disable Lint/Debugger
end

Quand("je rafraîchis la page") do
  visit current_path
end
