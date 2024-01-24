# frozen_string_literal: true

Quand("je me rends sur la page d'accueil") do
  visit "/"
end

Quand("print the page") do
  log page.body
end

Quand("je clique sur {string}") do |label|
  click_link_or_button label
end

Alors("la page contient {string}") do |content|
  expect(page).to have_content(content)
end

Alors("la page ne contient pas {string}") do |content|
  expect(page).to have_no_content(content)
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

Quand("je remplis le champ {string} avec {string} dans les champs de {string}") do |label, value, fieldset_legend|
  within_fieldset(fieldset_legend) do
    fill_in label, with: value
  end
end

Quand("je décoche {string}") do |label|
  uncheck label
end

Quand("je coche {string}") do |label|
  check label
end

Quand("je clique sur {string} dans la rangée {string}") do |link, row|
  within("tr", text: row) do
    click_link_or_button(link)
  end
end

Quand("je clique sur {string} dans la dernière rangée") do |link|
  within(all("tr").last) do
    click_link_or_button(link)
  end
end

Quand("je remplis le champ {string} dans la rangée {string} avec {string}") do |locator, row, value|
  within("tr", text: row) do
    fill_in locator, with: value
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

Alors("je peux voir dans le tableau {string} dans cet ordre :") do |caption, table_data|
  within_table(caption) do
    table_data.rows.each_with_index do |row, row_number|
      row.each_with_index do |cel, cel_number|
        expect(find("tr[#{row_number + 1}]/td[#{cel_number + 1}]")).to have_text(cel)
      end
    end
  end
end

Alors("debug") do
  debugger # rubocop:disable Lint/Debugger
end

Quand("je rafraîchis la page") do
  visit current_path
end
