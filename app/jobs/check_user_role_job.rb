# frozen_string_literal: true

class CheckUserRoleJob < ApplicationJob
  class NoLastOperationalRoleError < StandardError; end
  class NoRuaResultError < StandardError; end

  attr_accessor :user

  def perform(user_id)
    @user = User.find(user_id)
    check_role
  end

  def check_role
    dir?
  rescue JSON::ParserError, NoLastOperationalRoleError, NoRuaResultError
    false
  end

  def rua_info
    infos = Omogen::Rua.new.synthese_info(@user.email)
    raise NoRuaResultError unless infos.size == 1

    infos[0]
  end

  def last_operational_role
    operational_roles = rua_info["affectationsOperationnelles"]
    raise NoLastOperationalRoleError if operational_roles.blank?

    operational_roles[0]
  end

  def dir?
    last_operational_role["specialiteEmploiType"] == Omogen::Rua::DIR_EMPLOI_TYPE
  end
end
