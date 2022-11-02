# frozen_string_literal: true

require "rails_helper"
require_relative "item_examples"

RSpec.describe Katalyst::Content::Column do
  subject(:column) { build(:katalyst_content_section, container: page) }

  let(:page) { create(:page) }

  it_behaves_like "a item" do
    let(:item) { column }
  end

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: column.heading) }

    context "when heading is hidden" do
      before { column.show_heading = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
