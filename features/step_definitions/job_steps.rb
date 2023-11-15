# frozen_string_literal: true

Quand("toutes les tâches de fond sont terminées") do
  perform_enqueued_jobs
end

Quand("la liste des élèves de l'établissement {string} est rafraîchie") do |uai|
  FetchStudentsJob.perform_later(Establishment.find_by(uai: uai))
end
