# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Content do
  subject(:content) { build :katalyst_content_content, container: page }

  let(:page) { create :page }

  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:heading) }
  it { is_expected.to validate_presence_of(:background) }
  it { is_expected.to validate_inclusion_of(:background).in_array(Katalyst::Content.config.backgrounds) }
  it { is_expected.to validate_presence_of(:content) }

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