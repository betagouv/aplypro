# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    attr_accessor :updatable_attributes

    def sourced_from_external_api(*args)
      self.updatable_attributes ||= []

      self.updatable_attributes += args
    end
  end
end
