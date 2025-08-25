# frozen_string_literal: true

module MenuHelper
  def current_path?(path)
    request.path.start_with?(path) && !current_path_is_validation?
  end

  def current_path_is_validation?
    request.path.include?("validation")
  end

  def current_path_is_abrogation?
    request.path.include?("abrogation")
  end
end
