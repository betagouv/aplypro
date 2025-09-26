# frozen_string_literal: true

module EstablishmentsApis
  class Base
    class << self
      def dataset
        raise NotImplementedError
      end

      def base_url
        "#{ENV.fetch('APLYPRO_DATA_EDUCATION_URL')}/#{dataset}"
      end
    end
  end
end
