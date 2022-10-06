# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Item do
  subject(:item) { build :katalyst_content_item, container: Page.new }

  it_behaves_like "a item"

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: item.heading) }

    context "when heading is hidden" do
      subject(:item) { build :katalyst_content_item, container: Page.new, show_heading: false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
