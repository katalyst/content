# frozen_string_literal: true

module Katalyst
  module Content
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
    end
  end
end
