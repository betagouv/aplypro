# frozen_string_literal: true

class FillEstablishmentsStudentsProvider < ActiveRecord::Migration[7.1]
  def up
    Establishment.includes(:users).find_each do |establishment|
      next if establishment.users.none? || establishment.users.first.provider.nil?

      provider = establishment.users.first.provider == "masa" ? :fregata : :sygne
      establishment.update!(students_provider: provider)
    end
  end
end
