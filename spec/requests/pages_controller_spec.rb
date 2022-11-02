# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController do
  subject { action && response }

  describe "GET /:slug" do
    let(:action) { get page_path(page.slug) }
    let(:page) { create(:page) }

    it { is_expected.to be_successful }
    it { is_expected.to have_rendered("pages/show") }
  end
end
