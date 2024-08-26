# frozen_string_literal: true

require "rails_helper"
require_relative "item_examples"

RSpec.describe Katalyst::Content::Aside do
  subject(:aside) { build(:katalyst_content_aside, container: page) }

  let(:page) { create(:page) }

  it_behaves_like "a item" do
    let(:item) { aside }
  end

  it "can round trip style attributes" do
    aside = create(:katalyst_content_aside, container: page, reverse: true)
    expect(aside.reload).to have_attributes(reverse: true)
  end

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: aside.heading) }

    context "when heading is hidden" do
      subject(:aside) { build(:katalyst_content_aside, heading_style: "none", container: page) }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
