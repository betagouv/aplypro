# frozen_string_literal: true

module DataEducationApi
  class Base
    class << self
      def dataset
        raise NotImplementedError
      end

      protected

      def client
        Faraday.new(
          url: base_url,
          headers: { "Content-Type" => "application/json" }
        ) do |f|
          f.response :json
        end
      end

      private

      def fetch!(param)
        raise NotImplementedError
      end

      def base_url
        "#{ENV.fetch('APLYPRO_DATA_EDUCATION_URL')}/#{dataset}"
      end
    end
  end
end
