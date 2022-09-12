# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController do
  subject { action && response }

  describe "GET /pages" do
    let(:action) { get pages_path }

    it { is_expected.to be_successful }
  end

  describe "GET /pages/new" do
    let(:action) { get new_page_path }

    it { is_expected.to be_successful }
  end

  describe "POST /pages" do
    let(:action) { post pages_path, params: { page: page_params } }
    let(:page_params) { attributes_for(:page) }

    it { is_expected.to redirect_to(page_path(assigns(:page))) }

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

  describe "GET /pages/:id" do
    let(:action) { get page_path(page) }
    let(:page) { create :page }

    it { is_expected.to be_successful }
  end

  describe "GET /pages/:id/edit" do
    let(:action) { get edit_page_path(page) }
    let(:page) { create :page }

    it { is_expected.to be_successful }
  end

  describe "PATCH /pages/:id" do
    let(:action) { patch page_path(page), params: { page: page_params } }
    let(:page) { create :page }
    let(:page_params) { { title: "updated" } }

    it { is_expected.to redirect_to(page_path(page)) }
    it { expect { action }.to change { page.reload.title }.from(page.title).to("updated") }
  end

  describe "DELETE /pages/:id" do
    let(:action) { delete page_path(page) }
    let!(:page) { create :page }

    it { is_expected.to have_http_status(:see_other) }
    it { is_expected.to redirect_to(pages_path) }
    it { expect { action }.to change(Page, :count).to(0) }
  end
end
