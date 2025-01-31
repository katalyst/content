# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Figure do
  subject(:figure) { build(:katalyst_content_figure, container: page) }

  let(:page) { create(:page) }

  it_behaves_like "a item" do
    let(:item) { figure }
  end

  it { is_expected.to validate_presence_of(:image) }

  it { is_expected.to validate_content_type_of(:image).allowing(*Katalyst::Content.config.image_mime_types) }
  it { is_expected.to validate_content_type_of(:image).rejecting("text/plain", "text/xml") }

  it "validates attachment size" do
    expect(figure).to validate_size_of(:image).less_than_or_equal_to(Katalyst::Content.config.max_image_size.megabytes)
  end

  describe "#to_plain_text" do
    it "has valid plain text" do
      expect(figure).to have_attributes(
        to_plain_text: "Image: #{figure.alt}\nCaption: #{figure.caption}",
      )
    end

    context "when heading is hidden" do
      subject(:figure) { build(:katalyst_content_figure, heading_style: "none", container: page) }

      it { is_expected.to have_attributes(to_plain_text: "Image: #{figure.alt}\nCaption: #{figure.caption}") }
    end
  end

  describe "#dup" do
    subject(:figure) { create(:katalyst_content_figure, container: page) }

    it "preserves page association on dup" do
      expect(figure.dup).to have_attributes(figure.attributes.slice("parent_id", "parent_type"))
    end

    it "copies attachment" do
      copy = figure.dup
      expect(copy.image).to be_new_record
    end

    it "preserves attachment" do
      copy = figure.dup
      expect(copy.image.blob).to eq(figure.image.blob)
    end

    context "with new attachment" do
      it "saves the new attachment data" do
        figure.image = Rack::Test::UploadedFile.new(Rails.root.parent.join("fixtures/images/sample.png"), "image/png")
        copy         = figure.dup
        copy.save!
        expect(ActiveStorage::Blob.service).to exist(copy.image.blob.key)
      end
    end
  end
end
