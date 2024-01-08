# frozen_string_literal: true

require "rails_helper"

RSpec.describe "katalyst/content/editor/container" do
  # Disabled because we need an HTML5 drag/drop implementation of `drag_to`.
  # Checked selenium, cuprite, and apparition and none of them have one
  # https://bugs.chromium.org/p/chromium/issues/detail?id=850071
  # > Right now the Action API cannot generate the drag and drop actions by
  # > sending the mouse press, mouse move and mouse release, because  the drag
  # > and drop events are generated from the OS level.
  it "can add a item", pending: "requires d&d" do
    container = create(:page)

    visit admin_page_path(container)

    add_new_item = find("div[data-controller$='new-item']:first-child")
    drop_target = find("ol[data-controller$='list']")
    add_new_item.drag_to(drop_target)

    expect(page).to have_css("[data-controller$='list'] li[data-content-item]")

    fill_in "Heading", with: "Magic"
    click_on "Done"

    expect(page).to have_css("li", text: "Magic")

    click_on "Publish"

    expect(page).to have_link(class: "status-text", text: "Published", visible: :visible)

    page.reload

    expect(page.published_items).to contain_exactly(having_attributes(title: "Magic"))
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
    container = create(:page, items: [item])

    visit admin_page_path(container)

    find("a[title='Edit']").click
    fill_in "Heading", with: "Updated"
    click_on "Done"

    expect(page).to have_css("#items_page_#{container.id} > li", text: "Updated")

    click_on "Save"

    expect(page).to have_link(class: "status-text", text: "Draft", visible: :visible)

    container.reload

    expect(container.draft_items).to contain_exactly(having_attributes(heading: "Updated"))
  end

  it "can show errors on save" do
    item = build(:katalyst_content_item)
    container = create(:page, items: [item])

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
