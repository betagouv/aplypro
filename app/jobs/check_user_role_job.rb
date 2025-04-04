# frozen_string_literal: true

class CheckUserRoleJob < ApplicationJob
  attr_accessor :user

  def perform(user_id)
    @user = User.find(user_id)
  end

  def check_role
    Rua::Client.new.agent_info(user)
  end
end
