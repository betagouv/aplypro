# frozen_string_literal: true

class PrincipalsController < ApplicationController
  def update
    if current_principal.update!(principal_params)
      redirect_to classes_path
    else
      render action: :edit, status: :unprocessable_entity
    end
  end

  def update_establishment; end

  private

  def principal_params
    params.require(:principal).permit(:establishment_id)
  end
end
