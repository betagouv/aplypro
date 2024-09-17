# frozen_string_literal: true

Sachantque(
  "l'élève {string} en classe de {string} a toutes les informations nécessaires pour le paiement"
) do |name, classe|
  steps %(
    Sachant que l'API SYGNE renvoie une adresse en France pour l'élève "#{name}"
    Quand les informations personnelles ont été récupérées pour l'élève "#{name}"
    Et que l'élève "#{name}" a bien le statut étudiant
  )

  if find_student_by_full_name(name).ribs.empty?
    steps %(
      Et que je renseigne les coordonnées bancaires de l'élève "#{name}" de la classe "#{classe}"
    )
  end

  steps %(
    Et que je génère les décisions d'attribution de mon établissement
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "#{name}" dans la classe de "#{classe}"
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement incomplète"
) do |name, classe|
  steps %(
    Quand l'élève "#{name}" en classe de "#{classe}" a toutes les informations nécessaires pour le paiement
    Mais que l'élève "#{name}" n'a pas d'INE
    Et que les tâches de préparation et d'envoi des paiements sont passées
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement prête à l'envoi"
) do |name, classe|
  steps %(
    Quand l'élève "#{name}" en classe de "#{classe}" a toutes les informations nécessaires pour le paiement
    Et que la tâche de préparation des paiements est passée
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement envoyée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement prête à l'envoi
    Et que la tâche d'envoi des paiements est passée
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement intégrée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement envoyée
    Et que l'ASP a accepté le dossier de "#{name}"
    Et que la tâche de lecture des paiements est passée
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement rejetée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement envoyée
    Et que l'ASP a rejetté le dossier de "#{name}" avec un motif de "mauvais RIB"
    Et que la tâche de lecture des paiements est passée
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement liquidée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement intégrée
    Et que l'ASP a liquidé le paiement de "#{name}"
    Et que la tâche de lecture des paiements est passée
  )
end

Sachantque(
  "la dernière PFMP de {string} en classe de {string} a une requête de paiement échouée"
) do |name, classe|
  steps %(
    Quand la dernière PFMP de "#{name}" en classe de "#{classe}" a une requête de paiement intégrée
    Et que l'ASP n'a pas pu liquider le paiement de "#{name}"
    Et que la tâche de lecture des paiements est passée
  )
end
