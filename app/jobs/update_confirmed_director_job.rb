# frozen_string_literal: true

class UpdateConfirmedDirectorJob < ApplicationJob
  class NoListedDirector < StandardError; end
  class MultipleDirector < StandardError; end

  attr_accessor :user

  def perform(uai)
    @establishment = Establishment.find_by!(uai: uai)
    update_confirmed_director!
  end

  private

  def update_confirmed_director!
    rua_info = Rua::Client.new.dirs_for_uai(@establishment.uai)
    raise NoListedDirector if rua_info.blank?
    raise MultipleDirector if rua_info.size > 1

    dir_email = rua_info.first["mails"].first["libelle"]

    user = User.find_by!(email: dir_email)
    @establishment.update!(confirmed_director: user)
  end
end
