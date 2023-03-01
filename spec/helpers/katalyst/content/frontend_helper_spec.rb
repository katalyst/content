# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::FrontendHelper do
  let(:page) { create(:page, items: [item]) }
  let(:item) { build(:katalyst_content_section, heading: "Section heading") }
  let(:version) { page.published_version }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    allow(controller).to receive(:perform_caching).and_return(true)
    allow(controller).to receive(:cache_store).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#render_content" do
    let(:rendered_html) { helper.render_content(version) }

    it { expect(rendered_html).to include("Section heading") }

    context "with no content" do
      let(:page) { create(:page) }

      it { expect(rendered_html).to be_blank }
    end

    context "with no caching" do
      before do
        allow(controller).to receive(:perform_caching).and_return(false)
      end

      it "does not cache generated content" do
        allow(version).to(receive(:tree).and_return([]))
        helper.render_content(version)
        helper.render_content(version)

        expect(version).to have_received(:tree).twice
      end
    end

    context "with caching" do
      before do
        allow(controller).to receive(:perform_caching).and_return(true)
      end

      it "caches generated content" do
        allow(version).to(receive(:tree).and_return([]))
        helper.render_content(version)
        helper.render_content(version)

        expect(version).to have_received(:tree).once
      end
    end
  end
end
