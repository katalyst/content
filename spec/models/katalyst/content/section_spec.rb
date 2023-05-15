# frozen_string_literal: true

require "rails_helper"
require_relative "item_examples"

RSpec.describe Katalyst::Content::Section do
  subject(:section) { build(:katalyst_content_section, container: page) }

  let(:page) { create(:page) }

  it_behaves_like "a item" do
    let(:item) { section }
  end

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: section.heading) }

    context "when heading is hidden" do
      subject(:section) { build(:katalyst_content_section, heading_style: "none", container: page) }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
