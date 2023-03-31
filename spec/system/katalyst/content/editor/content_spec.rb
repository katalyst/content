# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/editor/content" do
  it "can add an anchor link" do
    item = build(:katalyst_content_content, content: "testing link editing")
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click

    # wait for editor to load
    expect(page).to have_button(text: "Link")

    find("trix-editor").click

    page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([8,12])")

    click_on "Link"
    fill_in "Enter a URL…", with: "#anchor"
    within(".trix-dialog.trix-active") { click_on "Link" }

    click_on "Done"

    expect(page).to have_link(class: "status-text", text: "Draft", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    visit page_path(container.slug)

    expect(page).to have_link(text: "link", href: "#anchor")
  end

  it "can add a heading" do
    item = build(:katalyst_content_content, content: "testing headings")
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click

    # wait for editor to load
    expect(page).to have_button(text: "Heading")

    find("trix-editor").click

    page.execute_script("document.querySelector('trix-editor').editor.setSelectedRange([0,0])")

    click_on "Heading"
    click_on "Done"

    expect(page).to have_link(class: "status-text", text: "Draft", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    visit page_path(container.slug)

    expect(page).to have_css("h4", text: "testing headings")
  end

  # regression test for headings not being detected on first interaction
  it "can modify an existing heading" do
    item = build(:katalyst_content_content, content: "<h4>testing headings</h4>")
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click

    # wait for editor to load
    expect(page).to have_css("trix-editor h4")

    # ensure heading has correctly identified that the first element is a heading
    expect(page).to have_selector("button[data-trix-attribute=heading4]", class: "trix-active")
  end
end
