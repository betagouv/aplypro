# frozen_string_literal: true

Quand("toutes les tâches de fond sont terminées") do
  perform_enqueued_jobs
end
