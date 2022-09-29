# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Section do
  subject(:section) { build :katalyst_content_section, container: page }

  let(:page) { create :page }

  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:heading) }
  it { is_expected.to validate_presence_of(:background) }
  it { is_expected.to validate_inclusion_of(:background).in_array(Katalyst::Content.config.backgrounds) }

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: section.heading) }

    context "when heading is hidden" do
      subject(:section) { build :katalyst_content_section, container: Page.new, show_heading: false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end

    context "when section is not visible" do
      subject(:section) { build :katalyst_content_section, container: Page.new, visible: false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
