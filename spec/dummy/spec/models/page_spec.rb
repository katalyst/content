# frozen_string_literal: true

require "rails_helper"

RSpec.describe Page do
  subject(:page) { create :page }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:slug).ignoring_case_sensitivity }

  describe "#title=" do
    let(:update) { page.update(title: "Updated") }

    it { expect { update }.to change(page, :title) }
  end

  describe "#slug=" do
    let(:update) { page.update(slug: "updated") }

    it { expect { update }.to change(page, :slug) }
  end
end
