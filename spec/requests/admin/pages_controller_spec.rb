# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PagesController do
  subject { action && response }

  describe "GET /admin/pages" do
    let(:action) { get admin_pages_path }

    it { is_expected.to be_successful }
  end

  describe "GET /admin/pages/new" do
    let(:action) { get new_admin_page_path }

    it { is_expected.to be_successful }
  end

  describe "POST /admin/pages" do
    let(:action) { post admin_pages_path, params: { page: page_params } }
    let(:page_params) { attributes_for(:page) }

    it { is_expected.to redirect_to(admin_page_path(assigns(:page))) }

    it { expect { action }.to change(Page, :count).by(1) }

    it "sets attributes correctly" do
      action
      expect(assigns(:page)).to have_attributes(page_params)
    end

    context "with invalid params" do
      let(:page_params) { { title: "" } }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Page, :count) }
    end
  end

  describe "GET /admin/pages/:id" do
    let(:action) { get admin_page_path(page) }
    let(:page) { create :page }

    it { is_expected.to be_successful }
  end

  describe "GET /admin/pages/:id/edit" do
    let(:action) { get edit_admin_page_path(page) }
    let(:page) { create :page }

    it { is_expected.to be_successful }
  end

  describe "PATCH /admin/pages/:id" do
    let(:action) { patch admin_page_path(page), params: { page: page_params } }
    let(:page) { create :page }
    let(:page_params) { { title: "updated" } }

    it { is_expected.to redirect_to(admin_page_path(page)) }
    it { expect { action }.to change { page.reload.title }.from(page.title).to("updated") }
  end

  describe "DELETE /admin/pages/:id" do
    let(:action) { delete admin_page_path(page) }
    let!(:page) { create :page }

    it { is_expected.to have_http_status(:see_other) }
    it { is_expected.to redirect_to(admin_pages_path) }
    it { expect { action }.to change(Page, :count).to(0) }
  end
end
