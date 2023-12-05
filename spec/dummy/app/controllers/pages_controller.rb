# frozen_string_literal: true

class PagesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  def show
    render locals: { page: }
  end

  private

  def page
    @page ||= Page.find_by!(slug: params[:slug])
  end
end
