# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Content do
  subject(:content) { build :katalyst_content_content, container: page }

  let(:page) { create :page }

  it_behaves_like "a item" do
    let(:item) { content }
  end

  it { is_expected.to validate_presence_of(:content) }

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: "#{content.heading}\n#{content.content.to_plain_text}") }

    context "when heading is hidden" do
      subject(:content) { build :katalyst_content_content, container: page, show_heading: false }

      it { is_expected.to have_attributes(to_plain_text: content.content.to_plain_text.to_s) }
    end
  end

  describe "#dup" do
    subject(:content) { create :katalyst_content_content, container: page }

    it "preserves page association on dup" do
      expect(content.dup).to have_attributes(content.attributes.slice("parent_id", "parent_type"))
    end

    it "copies rich text" do
      copy = content.dup
      expect(copy.content).to be_new_record
    end

    it "preserves rich text content" do
      copy = content.dup
      expect(copy.content.body).to eq(content.content.body)
    end
  end
end
