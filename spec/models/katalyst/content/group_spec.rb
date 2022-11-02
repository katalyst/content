# frozen_string_literal: true

require "rails_helper"
require_relative "item_examples"

RSpec.describe Katalyst::Content::Group do
  subject(:group) { build(:katalyst_content_group, container: page) }

  let(:page) { create(:page) }

  it_behaves_like "a item" do
    let(:item) { group }
  end

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: group.heading) }

    context "when heading is hidden" do
      before { group.show_heading = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
