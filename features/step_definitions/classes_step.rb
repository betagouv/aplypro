# frozen_string_literal: true

Alors("je peux voir {int} PFMP(s) {string} pour la classe {string}") do |count, state, label|
  within("tr", text: label) do
    step(%(l'indicateur de PFMP "#{state}" affiche #{count}))
  end
end

Quand("je consulte l'année scolaire {string}") do |school_year|
  steps %(
    Quand je clique sur le premier "Changer d'année scolaire"
    Et que je clique sur "#{school_year}"
  )
end
