# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/content" do
  it "loads dummy app" do
    visit root_path

    expect(page).to have_text "Dummy app"
  end

  it "has stimulus configured" do
    visit root_path

    expect(page).to have_text "Dummy app - stimulus"
  end

  it "has turbo configured" do
    visit root_path

    expect(page).to have_text "Turbo loaded"
  end
end
