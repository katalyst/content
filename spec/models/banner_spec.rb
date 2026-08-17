# frozen_string_literal: true

require "rails_helper"

RSpec.describe Banner do
  subject(:banner) { create(:banner, container: page) }

  let(:page) { create(:page) }

  describe "#dup" do
    it "preserves attachment" do
      expect(banner.dup.image.blob).to eq(banner.image.blob)
    end

    context "when the user has removed the attachment" do
      # govuk_attachment_field submits "" when the user makes no selection,
      # which Active Storage records as a DeleteOne attachment change
      before { banner.image = "" }

      it "removes the attachment from the copy" do
        expect(banner.dup.image).not_to be_attached
      end

      it "produces a copy that can be saved without the attachment" do
        copy = banner.dup
        copy.save!
        expect(copy.reload.image).not_to be_attached
      end
    end
  end

  describe "#dup slides (has_many_attached)" do
    before { banner.slides.attach([image_upload, image_upload]) }

    it "preserves attachments" do
      expect(banner.dup.slides.blobs).to eq(banner.slides.blobs)
    end

    context "with new attachments" do
      it "saves the new attachment data" do
        banner.slides = [image_upload, image_upload]
        copy          = banner.dup
        copy.save!
        expect(copy.slides.blobs).to satisfy("all exist in storage") do |blobs|
          blobs.count == 2 && blobs.all? { |blob| ActiveStorage::Blob.service.exist?(blob.key) }
        end
      end
    end

    context "when the user has removed the attachments" do
      # a multi-select govuk_attachment_field submits [""] when the user
      # makes no selection, which Active Storage records as a DeleteMany
      # attachment change
      before { banner.slides = [""] }

      it "removes the attachments from the copy" do
        expect(banner.dup.slides).not_to be_attached
      end

      it "produces a copy that can be saved without the attachments" do
        copy = banner.dup
        copy.save!
        expect(copy.reload.slides).not_to be_attached
      end
    end

    context "when an attachment is marked for destruction" do
      it "copies only the remaining attachments" do
        first, second = banner.slides_attachments.to_a
        first.mark_for_destruction
        expect(banner.dup.slides.blobs).to eq([second.blob])
      end
    end
  end
end
