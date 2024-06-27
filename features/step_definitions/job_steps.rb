# frozen_string_literal: true

Quand("toutes les tâches de fond sont terminées") do
  perform_enqueued_jobs
end

# NOTE: il arrive qu'une tâche déclence d'autres tâches, comme
# GenerateAttributiveDecisionsJob qui appelle
# FetchStudentInformationJob ou bien ConsiderPaymentRequestsJob qui
# appelle PreparePaymentRequestJob, etc. Dans ces cas là il faut
# épuiser la file de tâches deux fois pour lancer d'abord la tâche
# puis ensuite les sous-tâches.
Quand("toutes les tâches de fond et leurs sous-tâches sont terminées") do
  steps %(
    Et que toutes les tâches de fond sont terminées
    Et que toutes les tâches de fond sont terminées
  )
end

Quand("la liste des élèves de l'établissement {string} est rafraîchie") do |uai|
  FetchStudentsJob.perform_later(Establishment.find_by(uai: uai))
end

# NOTE: pas très élégant mais comme le job parent
# (GenerateMissingAttributiveDecisionsJob) déclenche un job par DA, il
# faut perform non pas une mais deux fois la liste des tâches pour que
# tout soit vraiment fini.
Quand("la génération des décisions d'attribution manquantes est complètement finie") do
  step("toutes les tâches de fond et leurs sous-tâches sont terminées")
end
