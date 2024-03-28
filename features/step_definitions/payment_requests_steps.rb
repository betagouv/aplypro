# frozen_string_literal: true

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement prête à l'envoi"
) do |name, classe|
  steps %(
    Et que l'élève "#{name}" a des données correctes pour l'ASP
    Et que les informations personnelles ont été récupérées pour l'élève "#{name}"
    Et que je génère les décisions d'attribution de mon établissement
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "#{name}" dans la classe de "#{classe}"
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement envoyée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement prête à l'envoi
    Et que les tâches de préparation et d'envoi des paiements sont passées
  )
end
