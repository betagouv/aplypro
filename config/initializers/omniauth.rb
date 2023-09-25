# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

# NOTE: this code allows for multiple-choice fields in the Omniauth
# dev strategy, rendered as <select> elements. It's not the best code
# but it will allow the team to try logging in as any establishment
# with the relevant ministry.
module OmniAuth
  class Form
    def select_field(hash)
      key, values = hash.first

      label_field(key, key.capitalize)

      @html << "\n<select name='#{key}'>\n"

      values.each do |value|
        @html << "\n<option value='#{value}'>#{value}</option>"
      end

      @html << "\n</select>"
    end
  end

  module Strategies
    class Developer
      def request_phase
        form = OmniAuth::Form.new(title: "User Info", url: callback_path)
        options.fields.each do |field|
          if field.is_a? Hash
            form.select_field(field)
          else
            form.text_field field.to_s.capitalize.tr("_", " "), field.to_s
          end
        end
        form.button "Sign In"
        form.to_response
      end

      info do
        options.fields.each_with_object({}) do |field, hash|
          if field.is_a? Hash
            key = field.keys.first
            hash[key] = request.params[key]
          else
            hash[field] = request.params[field.to_s]
          end
        end
      end
    end
  end
end
