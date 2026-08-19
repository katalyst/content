# frozen_string_literal: true

module Admin
  class PagesController < ApplicationController
    helper Katalyst::Content::EditorHelper
    helper Katalyst::Tables::Frontend

    before_action :set_page, only: %i[show edit update destroy]

    attr_reader :page

    def index
      collection = Collection.with_params(params).apply(Page)

      render locals: { collection: }
    end

    def show
      render locals: { page:, editor: }
    end

    def new
      @page = Page.new

      render locals: { page: }
    end

    def edit
      render locals: { page: }
    end

    def create
      @page = Page.new(page_params)

      if page.save
        redirect_to [:admin, page], status: :see_other
      else
        render :new, locals: { page: }, status: :unprocessable_content
      end
    end

    # PATCH /admins/pages/:slug
    def update
      page.attributes = page_params

      unless page.valid?
        return respond_to do |format|
          format.turbo_stream { render editor.errors, status: :unprocessable_content }
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
      page.destroy!

      redirect_to action: :index, status: :see_other
    end

    private

    def set_page
      @page = Page.find(params.expect(:id))
    end

    def editor
      @editor ||= Katalyst::Content::EditorComponent.new(container: page)
    end

    def page_params
      return {} if params[:page].blank?

      params.expect(page: [:title, :slug, { items_attributes: [%i[id index depth]] }])
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
