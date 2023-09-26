# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  def create_attributive_decisions
    GenerateAttributiveDecisionsJob.perform_later(@etab)

    redirect_to classes_path, notice: t("flash.attributive_decisions_generating")
  end
end
