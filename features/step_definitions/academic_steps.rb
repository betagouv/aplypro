# frozen_string_literal: true

Quand("je me rend sur la page d'accueil du personnel académique") do
  visit "/academic/home"
end

Sachantque("il existe un établissement avec le code académie {string}") do |academy_code|
  school_year = SchoolYear.current
  establishment = FactoryBot.create(:establishment, academy_code: academy_code)
  classe = FactoryBot.create(:classe, establishment: establishment, school_year: school_year)

  schooling = FactoryBot.create(:schooling, classe: classe)
  FactoryBot.create(:pfmp, schooling: schooling)
end

Quand("je clique sur le nom de l'établissement dans le tableau") do
  within(".establishments-table") do
    first("a").click
  end
end
