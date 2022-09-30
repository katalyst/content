# frozen_string_literal: true

module FileHelper
  def image_upload(image = "sample.png", type: "image/png")
    Rack::Test::UploadedFile.new("spec/fixtures/images/#{image}", type)
  end
end
