# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  def create_attributive_decisions
    redirect_to classes_path, status: :forbidden and return if !current_user.can_generate_attributive_decisions?

    # NOTE: the job already toggles the progress indicator
    # (`generating_attributive_decisions = true`) but if the job is
    # slow to kick-off the page reload is too fast and we get the
    # redirect flash below + the dialog asking them to generate them.
    @etab.update!(generating_attributive_decisions: true)

    GenerateAttributiveDecisionsJob.perform_later(@etab)

    redirect_to root_path
  end
end
