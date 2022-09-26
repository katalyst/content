# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::DirectUploadsController do
  subject { action && response }

  describe "#create" do
    let(:action) { post katalyst_content.direct_uploads_url, params: params }
    let(:params) do
      {
        blob:          blob_params,
        direct_upload: { blob: blob_params },
      }
    end
    let(:image_data) { Rails.root.join("../fixtures/images/sample.png").read }
    let(:blob_params) do
      {
        filename:     "sample.png",
        content_type: "image/png",
        byte_size:    image_data.size,
        checksum:     OpenSSL::Digest::MD5.new(image_data).base64digest,
      }
    end

    it { is_expected.to be_successful }
    it { expect { action }.to change(ActiveStorage::Blob, :count).by(1) }
  end
end
