# frozen_string_literal: true

module Admin
  class PagesController < ApplicationController
    helper Katalyst::Content::EditorHelper
    helper Katalyst::Tables::Frontend

    def index
      collection = Collection.with_params(params).apply(Page)

      render locals: { collection: }
    end

    def new
      render locals: { page: Page.new }
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        redirect_to [:admin, @page]
      else
        render :new, locals: { page: @page }, status: :unprocessable_entity
      end
    end

    def show
      page   = Page.find(params[:id])
      editor = Katalyst::Content::EditorComponent.new(container: page)

      render locals: { page:, editor: }
    end

    def edit
      page = Page.find(params[:id])

      render locals: { page: }
    end

    # PATCH /admins/pages/:slug
    def update
      page = Page.find(params[:id])

      page.attributes = page_params

      unless page.valid?
        editor = Katalyst::Content::EditorComponent.new(container: page)

        return respond_to do |format|
          format.turbo_stream { render editor.errors, status: :unprocessable_entity }
        end
      end

      case params[:commit]
      when "publish"
        page.save!
        page.publish!
      when "save"
        page.save!
      when "revert"
        page.revert!
      end

      redirect_to [:admin, page], status: :see_other
    end

    def destroy
      page = Page.find(params[:id])

      page.destroy!

      redirect_to action: :index, status: :see_other
    end

    private

    def page_params
      return {} if params[:page].blank?

      params.require(:page).permit(:title, :slug, items_attributes: %i[id index depth])
    end

    class Collection < Katalyst::Tables::Collection::Base
      include Katalyst::Tables::Collection::Query

      config.sorting = :title

      attribute :title, :string
      attribute :slug, :string
      attribute :state, :enum, scope: :state
    end
  end
end
