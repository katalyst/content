# frozen_string_literal: true

class PagesController < ApplicationController
  helper Katalyst::Content::FrontendHelper

  before_action :set_page
  before_action :set_version

  attr_reader :page, :version

  def show
    render locals: { page:, version: }
  end

  def preview
    render :show, locals: { page:, version: }
  end

  private

  def set_page
    @page = Page.find_by!(slug: params.expect(:slug))
  end

  def set_version
    @version = action_name == "preview" ? page.draft_version : page.published_version
  end
end
