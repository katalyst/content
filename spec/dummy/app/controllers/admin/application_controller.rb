# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    helper Katalyst::Content::EditorHelper
    helper Katalyst::Tables::Frontend

    layout "admin"
  end
end
