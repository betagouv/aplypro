# frozen_string_literal: true

Quand("l'élève de SYGNE avec l'INE {string} a quitté l'établissement {string}") do |ine, uai|
  steps %(
    Sachant que l'API SYGNE renvoie un élève avec l'INE "#{ine}" qui a quitté l'établissement "#{uai}"
    Et que la liste des élèves de l'établissement "#{uai}" est rafraîchie
    Et que toutes les tâches de fond sont terminées
    )
end
