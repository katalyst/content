# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/editor/container" do
  it "can add a item" do
    container = create(:page)

    visit admin_page_path(container)

    click_on "Add content"
    click_on "Section"

    fill_in "Heading", with: "Magic"
    click_on "Done"

    expect(page).to have_css("li", text: "Magic")

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.published_items).to contain_exactly(having_attributes(heading: "Magic"))
  end

  it "can remove a item" do
    item = build(:katalyst_content_item)
    container = create(:page, items: [item])

    expect(container.draft_items).not_to be_empty

    visit admin_page_path(container)

    # find and click nest – checks for data-deny-remove to ensure rules have been applied
    find("li:not([data-deny-remove]) [data-action$='#remove']").click

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.published_items).to be_empty
  end

  it "can edit a item" do
    item = build(:katalyst_content_item)
    container = create(:page, items: [item])

    expect(container.draft_items).not_to be_empty

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.published_items).to contain_exactly(having_attributes(heading: "Updated"))
  end

  it "can re-order items", pending: "requires d&d" do
    items = build_list(:katalyst_content_item, 2)
    container = create(:page, items:)

    expect(container.items.map(&:heading)).to eq([items.first.heading, items.last.heading])

    visit admin_page_path(container)

    # ensure that rules engine has run before dragging
    find("li[data-content-item]:not([data-deny-drag]):first-child")

    first = find("li[data-content-index='0']")
    last  = find("li[data-content-index='1']")
    first.drag_to(last)

    # check that items have been re-ordered (implicit wait)
    expect(page).to have_css("li[data-content-index='1'][data-content-item-id='#{items.first.id}']")

    # check that state has changed
    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.published_items.map(&:heading)).to eq([items.last.heading, items.first.heading])
  end

  it "can nest items in sections" do
    items = [build(:katalyst_content_section), build(:katalyst_content_content)]
    container = create(:page, items:)

    expect(container.draft_items.map(&:depth)).to eq([0, 0])

    visit admin_page_path(container)

    # find and click nest – checks for data-deny-nest to ensure rules have been applied
    find("li[data-content-item-id='#{items.last.id}']:not([data-deny-nest]) [data-action$='#nest']").click

    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.published_items.map(&:depth)).to eq([0, 1])
  end

  it "cannot nest items that are not containers" do
    items = build_list(:katalyst_content_content, 2)
    container = create(:page, items:)

    expect(container.draft_items.map(&:depth)).to eq([0, 0])

    visit admin_page_path(container)

    expect(page).to have_no_css("li[data-content-item]:not([data-deny-nest]")
  end

  it "can save without publishing" do
    item = build(:katalyst_content_item)
    container = create(:page, :unpublished, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")

    click_on "Save"

    expect(page).to have_link(class: "status-text", text: "Unpublished", visible: :visible)

    container.reload

    expect(container.draft_items).to contain_exactly(having_attributes(heading: "Updated"))
  end

  it "can show errors on save" do
    item = build(:katalyst_content_item)
    container = create(:page, :unpublished, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")
    container.items.reload.destroy_all

    click_on "Save"

    expect(page).to have_text("Items are missing or invalid")
    expect(page).to have_css("span", class: "status-text", text: "Unsaved changes", visible: :visible)
  end

  it "can revert a change" do
    item = build(:katalyst_content_item)
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")

    click_on "Save"

    expect(page).to have_link(class: "status-text", text: "Draft", visible: :visible)

    click_on "Revert"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.draft_version).to eq(container.published_version)
  end

  it "can publish a change" do
    item = build(:katalyst_content_item)
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")

    click_on "Save"

    expect(page).to have_link(class: "status-text", text: "Draft", visible: :visible)

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    container.reload

    expect(container.draft_version).to eq(container.published_version)
    expect(container.published_items).to contain_exactly(having_attributes(heading: "Updated"))
  end
end
