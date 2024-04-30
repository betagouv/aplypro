# frozen_string_literal: true

module ASP
  class Filename
    TYPES = %i[rejects integrations payments].freeze

    attr_reader :filename

    def initialize(name)
      @filename = name
    end

    TYPES.each do |type|
      define_method "#{type}_file?" do
        kind == type
      end
    end

    def original_filename
      return if payments_file?

      filename_noext = File.basename(filename, ".*")

      name = if rejects_file?
               filename_noext.split("integ_idp_").last
             elsif integrations_file?
               filename_noext.split("generes_").last
             end

      "#{name}.xml"
    end

    def kind
      case File.basename(filename)
      when /^rejets_integ_idp/
        :rejects
      when /^identifiants_generes/
        :integrations
      else
        :payments
      end
    end

    def to_s
      filename
    end
  end
end
