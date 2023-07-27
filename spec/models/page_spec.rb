# frozen_string_literal: true

require "rails_helper"

def transform_tree(nodes, &block)
  output = []
  nodes.each do |node|
    output << yield(node)
    output << transform_tree(node.children, &block) if node.children.any?
  end
  output
end

RSpec.describe Page do
  subject(:page) { create(:page, items: items) }

  let(:first) { build(:katalyst_content_item, heading: "First") }
  let(:last) { build(:katalyst_content_item, heading: "Last") }
  let(:items) { [first, last] }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:slug).ignoring_case_sensitivity }

  it { expect(page.items).to eq(items) }

  it "validates items" do
    expect(page).not_to allow_value([{ id: 404, depth: 0, index: 0 }])
                          .for(:items_attributes)
                          .with_message(I18n.t("activerecord.errors.messages.missing_item"), against: :items)
  end

  it { is_expected.to have_attributes(state: :published) }
  it { expect(page.draft_version).to eq(page.published_version) }

  it "stores the expect json (id/depth but no index)" do
    expect(page.published_nodes.as_json).to eq([{ id: first.id, depth: 0 }.as_json,
                                                { id: last.id, depth: 0 }.as_json])
  end

  it { expect(page.published_items).to eq(items) }
  it { expect(page.published_tree).to eq(items) }

  describe "#destroy" do
    before { page }

    it "deletes versions" do
      expect { page.destroy! }.to change(Page::Version, :count).to(0)
    end

    it "deletes items" do
      expect { page.destroy! }.to change(Katalyst::Content::Item, :count).to(0)
    end
  end

  shared_examples "an un-versioned change" do
    it "does not change state" do
      expect { update }.not_to change(page, :state)
    end

    it "does not change versions" do
      expect { update }.not_to change(page, :draft_version)
    end
  end

  describe "#title=" do
    let(:update) { page.update(title: "Updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(page, :title) }
  end

  describe "#slug=" do
    let(:update) { page.update(slug: "updated") }

    it_behaves_like "an un-versioned change"

    it { expect { update }.to change(page, :slug) }
  end

  describe "#published?" do
    it { expect(create(:page)).to be_published }
    it { expect(create(:page, :unpublished)).not_to be_published }
  end

  describe ".versions.active" do
    it "filters unused versions" do
      published = page.published_version
      draft     = page.draft_version
      _unused   = page.versions.create
      expect(page.versions.active).to match_array([published, draft].uniq.compact)
    end
  end

  describe ".versions.inactive" do
    it "filters used versions" do
      unused = page.versions.create
      expect(page.versions.inactive).to contain_exactly(unused)
    end
  end

  describe ".published" do
    it "filters published versions" do
      create(:page, :unpublished)
      published_page = create(:page)

      expect(described_class.published).to contain_exactly(published_page)
    end
  end

  shared_examples "a versioned change" do
    it "changes state" do
      expect { update }.to change(page, :state).from(:published).to(:draft)
    end

    it "creates a new version" do
      expect { update }.to change(page, :draft_version)
    end

    it "does not publish the new version" do
      expect { update }.not_to change(page, :published_version)
    end
  end

  describe "add item" do
    let(:update) do
      update = create(:katalyst_content_item, container: page, heading: "Update")
      page.update(items_attributes: page.draft_nodes + [{ id: update.id }])
      update
    end

    it_behaves_like "a versioned change"

    it "adds item" do
      expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                             .from(%w[First Last])
                             .to(%w[First Last Update])
    end

    context "with controller formatted attributes" do
      let(:update) do
        update     = create(:katalyst_content_item, container: page, heading: "Update")
        attributes = { "0" => { id: first.id.to_s, index: "0", depth: "0" },
                       "1" => { id: update.id.to_s, index: "2", depth: "0" },
                       "2" => { id: last.id.to_s, index: "1", depth: "0" } }
        page.update(items_attributes: attributes)
      end

      it "adds item" do
        expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                               .from(%w[First Last])
                               .to(%w[First Last Update])
      end
    end
  end

  describe "remove item" do
    let(:update) do
      page.update(items_attributes: page.draft_nodes.take(1))
    end

    it_behaves_like "a versioned change"

    it "removes item" do
      expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                             .from(%w[First Last])
                             .to(%w[First])
    end
  end

  describe "swap two items" do
    let(:update) do
      update = create(:katalyst_content_item, container: page, heading: "Update")
      page.update(items_attributes: [{ id: first.id },
                                     { id: update.id }])
    end

    it_behaves_like "a versioned change"

    it "changes item" do
      expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                             .from(%w[First Last])
                             .to(%w[First Update])
    end
  end

  describe "reorder items" do
    let(:update) do
      page.update(items_attributes: [{ id: last.id },
                                     { id: first.id }])
    end

    it_behaves_like "a versioned change"

    it "changes order" do
      expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                             .from(%w[First Last])
                             .to(%w[Last First])
    end
  end

  describe "change depth" do
    let(:update) do
      page.update(items_attributes: [{ id: first.id, depth: 0 },
                                     { id: last.id, depth: 1 }])
    end

    it_behaves_like "a versioned change"

    it "changes nesting" do
      expect { update }.to change { transform_tree(page.reload.draft_tree, &:heading) }
                             .from(%w[First Last])
                             .to(["First", ["Last"]])
    end
  end

  shared_context "when in the future" do
    before { travel(1.day) }
  end

  describe "#publish!" do
    let(:item_attributes) { page.draft_nodes.take(1) }

    before do
      page.update(items_attributes: item_attributes)
    end

    it "changes published version" do
      published = page.published_version
      draft     = page.draft_version
      expect { page.publish! }.to change(page, :published_version).from(published).to(draft)
    end

    it "removes orphaned version" do
      expect { page.publish! }.to change(page.versions, :count).by(-1)
    end

    it "removes orphaned published version" do
      previous = page.published_version
      page.publish!
      expect(page.versions.where(id: previous)).to be_empty
    end

    it "doesn't remove orphaned item" do
      expect { page.publish! }.not_to change(Katalyst::Content::Item, :count)
    end

    context "when orphaned items that have expired" do
      include_context "when in the future"

      it { expect { page.publish! }.to change(Katalyst::Content::Item, :count).by(-1) }

      it "removes the correct item" do
        orphaned = page.published_items.map(&:id) - page.draft_items.map(&:id)
        page.publish!
        expect(page.items.where(id: orphaned)).to be_empty
      end
    end
  end

  describe "#unpublish!" do
    let(:item_attributes) { page.draft_nodes.take(1) }

    before do
      page.update(items_attributes: item_attributes)
    end

    it "changes published version" do
      published = page.published_version
      expect { page.unpublish! }.to change(page, :published_version).from(published).to(nil)
    end

    it "removes orphaned version" do
      expect { page.unpublish! }.to change(page.versions, :count).by(-1)
    end

    it "removes orphaned published version" do
      previous = page.published_version
      page.unpublish!
      expect(page.versions.where(id: previous)).to be_empty
    end

    it "doesn't remove orphaned item" do
      expect { page.unpublish! }.not_to change(Katalyst::Content::Item, :count)
    end
  end

  describe "#revert!" do
    let(:item_attributes) { page.draft_nodes.take(1) }

    before do
      page.update(items_attributes: item_attributes)
      page.reload
    end

    it "changes draft version" do
      page.update(items_attributes: page.draft_nodes.take(1))
      published = page.published_version
      draft     = page.draft_version
      expect { page.revert! }.to change(page, :draft_version).from(draft).to(published)
    end

    it "removes orphaned version" do
      expect { page.revert! }.to change(page.versions, :count).by(-1)
    end

    it "removes orphaned latest version" do
      latest = page.draft_version
      page.revert!
      expect(page.versions.find_by(id: latest.id)).to be_nil
    end

    it "does not remove items" do
      travel 1.day
      expect { page.revert! }.not_to change(page.items, :count)
    end

    context "with multiple item changes" do
      let(:multiple_items) { create_list(:katalyst_content_item, 2, container: page) }
      let(:item_attributes) { [{ id: multiple_items.first.id, depth: 0 }, { id: multiple_items.last.id, depth: 1 }] }

      include_context "when in the future"

      it { expect { page.revert! }.to change(page.reload.items, :count).by(-2) }

      it "removes updated item" do
        page.revert!
        expect(Katalyst::Content::Item.where(id: multiple_items.map(&:id))).to be_empty
      end
    end
  end

  describe "#published_text" do
    subject(:page) { create(:page, items: items) }

    context "with heading" do
      let(:items) { build_list(:katalyst_content_content, 1, heading: "HEADING", content: "BODY") }

      it { expect(page).to have_attributes(published_text: "HEADING\nBODY") }
    end

    context "without heading" do
      let(:items) do
        build_list(:katalyst_content_content, 1, heading_style: "none", heading: "HEADING", content: "BODY")
      end

      it { expect(page).to have_attributes(published_text: "BODY") }
    end

    context "with multiple items" do
      let(:items) { build_list(:katalyst_content_content, 3, heading_style: "none", content: "BODY") }

      it { expect(page).to have_attributes(published_text: "BODY\nBODY\nBODY") }
    end
  end
end
