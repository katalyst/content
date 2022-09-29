# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/page" do
  it "renders page" do
    items     = [
      build(:katalyst_content_section, heading: "Section heading"),
      build(:katalyst_content_content, heading: "Nested content", depth: 1, content: <<~HTML
        <div>This is a text</div>
      HTML
      ),
      build(:katalyst_content_content, content: <<~HTML
        <div>This is a sub text</div>
      HTML
      ),
    ]
    container = create :page, items: items

    visit page_path(container.slug)

    within("#section-heading") do
      expect(page).to have_text("Section heading")
      expect(page).to have_text("Nested content")
    end

    expect(page).to have_text("This is a sub text")
  end
end
