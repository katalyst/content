# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    render locals: { page: page }
  end

  private

  def page
    @page ||= Page.find_by!(slug: params[:slug])
  end
end
