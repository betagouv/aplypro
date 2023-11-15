# frozen_string_literal: true

require Rails.root.join "spec/support/webmock_helpers.rb"

Quand("l'élève avec l'INE {string} a quitté l'établissement {string}") do |ine, uai|
  steps %(
    Sachant que l'API SYGNE renvoie un élève avec l'INE "#{ine}" qui a quitté l'établissement "#{uai}"
    Et que la liste des élèves de l'établissement "#{uai}" est rafraîchie
    Et que toutes les tâches de fond sont terminées
    )
end
