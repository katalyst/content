# frozen_string_literal: true

class PagesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  def show
    render locals: { page:, version: page.published_version }
  end

  def preview
    render :show, locals: { page:, version: page.draft_version }
  end

  private

  def page
    @page ||= Page.find_by!(slug: params[:slug] || params[:page_slug])
  end
end
