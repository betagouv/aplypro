# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    attr_accessor :updatable_attributes

    # TODO: rename to sourced_from_external_api or something like that
    def updatable(*args)
      self.updatable_attributes ||= []

      self.updatable_attributes += args
    end
  end
end
