# frozen_string_literal: true

module MenuHelper
  def current_path?(path)
    request.path.start_with?(path)
  end
end
