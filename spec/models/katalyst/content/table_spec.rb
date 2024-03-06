# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Table do
  subject(:table) { build(:katalyst_content_table, container: page) }

  let(:page) { create(:page) }

  it { is_expected.to be_valid }
  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:content) }

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: table.content.to_plain_text) }

    context "when item is not visible" do
      before { table.visible = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end

  describe "#dup" do
    it "preserves page association on dup" do
      expect(table.dup).to have_attributes(table.attributes.slice("parent_id", "parent_type"))
    end

    it "copies rich text" do
      copy = table.dup
      expect(copy.content).to be_new_record
    end

    it "preserves rich text content" do
      copy = table.dup
      expect(copy.content.body).to eq(table.content.body)
    end
  end
end
