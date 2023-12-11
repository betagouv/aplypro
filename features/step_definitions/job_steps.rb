# frozen_string_literal: true

Quand("toutes les tâches de fond sont terminées") do
  perform_enqueued_jobs
end

Quand("la liste des élèves de l'établissement {string} est rafraîchie") do |uai|
  FetchStudentsJob.perform_later(Establishment.find_by(uai: uai))
end

# NOTE: pas très élégant mais comme le job parent
# (GenerateMissingAttributiveDecisionsJob) déclenche un job par DA, il
# faut perform non pas une mais deux fois la liste des tâches pour que
# tout soit vraiment fini.
Quand("la génération des décisions d'attribution manquantes est complètement finie") do
  perform_enqueued_jobs
  perform_enqueued_jobs
end
