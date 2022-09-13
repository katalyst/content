# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Content do
  subject { build :katalyst_content_content, container: Page.new }

  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:heading) }
  it { is_expected.to validate_presence_of(:background) }
  it { is_expected.to validate_inclusion_of(:background).in_array(Katalyst::Content.config.backgrounds) }
  it { is_expected.to validate_presence_of(:content) }
end
