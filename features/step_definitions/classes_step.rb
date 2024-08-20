# frozen_string_literal: true

Quand("je me rends sur la page classes") do
  visit "/year/#{SchoolYear.current.start_year}/classes"
end

Alors("je peux voir {int} PFMP(s) {string} pour la classe {string}") do |count, state, label|
  within("tr", text: label) do
    step(%(l'indicateur de PFMP "#{state}" affiche #{count}))
  end
end
