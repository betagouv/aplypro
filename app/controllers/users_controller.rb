# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :check_current_establishment, only: :update

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to root_path
    else
      render :select_establishment, status: :unprocessable_content
    end
  end

  def select_establishment
    infer_page_title

    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:selected_establishment_id)
  end
end
