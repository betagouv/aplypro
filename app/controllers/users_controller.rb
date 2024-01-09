# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :set_establishment, only: :update

  def update
    if current_user.update!(user_params)
      redirect_to root_path
    else
      render action: :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:establishment_id)
  end
end
