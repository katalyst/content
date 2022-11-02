# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::ItemsController do
  subject { action && response }

  let(:container) { create(:page) }
  let(:default_item_params) { { type: item.class.name, container_id: container.id, container_type: "Page" } }
  let(:item) { build(:katalyst_content_content, container: container) }
  let(:item_params) { default_item_params }

  shared_examples "has attachment" do |attribute = :image|
    it "saves #{attribute}" do
      action
      expect(ActiveStorage::Blob.service).to be_exist(assigns(:item).send(attribute).blob.key)
    end
  end

  shared_examples "changes attachment" do |attribute = :image|
    it "saves #{attribute}" do
      action
      expect(ActiveStorage::Blob.service).to be_exist(assigns(:item).send(attribute).blob.key)
    end

    it "changes #{attribute}" do
      action
      expect(assigns(:item).send(attribute).blob.key).not_to eq item.send(attribute).blob.key
    end

    it "does not change original item" do
      expect { action }.not_to(change { item.reload.send(attribute).blob.key })
    end
  end

  describe "GET /items/new" do
    let(:action) { get katalyst_content.new_item_path, params: { item: item_params } }

    it { is_expected.to be_successful }
  end

  describe "POST /items" do
    let(:action) { post katalyst_content.items_path, params: { item: item_params }, as: :turbo_stream }
    let(:item_params) { attributes_for(:katalyst_content_content).merge(default_item_params) }

    it { is_expected.to be_successful }

    it { expect { action }.to change(Katalyst::Content::Content, :count).by(1) }

    context "with figure" do
      let(:item) { build(:katalyst_content_figure, container: container) }
      let(:item_params) { attributes_for(:katalyst_content_figure).merge(default_item_params) }

      it { is_expected.to be_successful }

      it { expect { action }.to change(Katalyst::Content::Figure, :count).by(1) }

      it_behaves_like "has attachment"
    end

    context "with invalid params" do
      let(:item_params) { { heading: "" }.merge(default_item_params) }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Katalyst::Content::Content, :count) }
    end
  end

  describe "GET /items/:id/edit" do
    let(:action) { get katalyst_content.edit_item_path(item) }
    let(:item) { create(:katalyst_content_content, container: container) }

    it { is_expected.to be_successful }
  end

  describe "PATCH /items/:id" do
    let(:action) { patch katalyst_content.item_path(item), params: { item: item_params }, as: :turbo_stream }
    let!(:item) { create(:katalyst_content_content, container: container) }
    let(:item_params) { { heading: "A new level" }.merge(default_item_params) }

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(item, :heading) }
    it { expect { action }.to change(Katalyst::Content::Content, :count).by(1) }

    it "sets title in the new link version" do
      action
      expect(assigns(:item).heading).to eq("A new level")
    end

    context "with invalid params" do
      let(:item_params) { { heading: "" }.merge(default_item_params) }

      it { is_expected.to be_unprocessable }
    end

    context "with figure" do
      let(:item) { create(:katalyst_content_figure, container: container) }
      let(:item_params) { { image: image_upload("simple.png") }.merge(default_item_params) }

      it_behaves_like "changes attachment"
    end
  end
end
