# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  cattr_accessor :_updatable_attributes, default: []

  class << self
    def updatable_attributes(*args)
      self._updatable_attributes += args
    end
  end
end
