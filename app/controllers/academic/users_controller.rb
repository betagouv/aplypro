# frozen_string_literal: true

module Academic
  class UsersController < ApplicationController
    before_action :infer_page_title

    def select_academy
      @academic_user = current_user
    end
  end
end
