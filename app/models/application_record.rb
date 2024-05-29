# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.updatable_attributes
    attribute_names.map(&:to_sym)
  end
end
