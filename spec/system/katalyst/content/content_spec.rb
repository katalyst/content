# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/content" do
  it "loads dummy app" do
    visit root_path

    expect(page).to have_css("h1", text: "Content")
  end
end
