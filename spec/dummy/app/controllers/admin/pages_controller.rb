# frozen_string_literal: true

module Admin
  class PagesController < ApplicationController
    include Katalyst::Tables::Backend

    helper Katalyst::Tables::Frontend

    def index
      sort, pages = table_sort(Page.all)

      render locals: { pages: pages, sort: sort }
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
      page = Page.find(params[:id])

      render locals: { page: page }
    end

    def edit
      page = Page.find(params[:id])

      render locals: { page: page }
    end

    # PATCH /admins/pages/:slug
    def update
      page = Page.find(params[:id])

      page.attributes = page_params

      unless page.save
        return render :show, locals: { page: page }, status: :unprocessable_entity
      end

      redirect_to [:admin, page]
    end

    def destroy
      page = Page.find(params[:id])

      page.destroy!

      redirect_to action: :index, status: :see_other
    end

    private

    def page_params
      return {} if params[:page].blank?

      params.require(:page).permit(:title, :slug)
    end
  end
end
