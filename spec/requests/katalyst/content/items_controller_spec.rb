# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::ItemsController do
  subject { action && response }

  let(:container) { create :page }
  let(:item_params) { { type: Katalyst::Content::Content.name, container_id: container.id, container_type: "Page" } }

  describe "GET /items/new" do
    let(:action) { get katalyst_content.new_item_path, params: { item: item_params } }

    it { is_expected.to be_successful }
  end

  describe "POST /items" do
    let(:action) do
      post katalyst_content.items_path,
           params: { item: content_params },
           as:     :turbo_stream
    end
    let(:content_params) { attributes_for(:katalyst_content_content).merge(item_params) }

    it { is_expected.to be_successful }

    it { expect { action }.to change(Katalyst::Content::Content, :count).by(1) }

    context "with invalid params" do
      let(:content_params) { { heading: "" }.merge(item_params) }

      it { is_expected.to be_unprocessable }
      it { expect { action }.not_to change(Katalyst::Content::Content, :count) }
    end
  end

  describe "GET /items:id/edit" do
    let(:action) { get katalyst_content.edit_item_path(content) }
    let(:content) { create :katalyst_content_content, container: container }

    it { is_expected.to be_successful }
  end

  describe "PATCH /items:id" do
    let(:action) do
      patch katalyst_content.item_path(content),
            params: { item: content_params },
            as:     :turbo_stream
    end
    let!(:content) { create :katalyst_content_content, container: container, heading: Faker::Beer.name }
    let(:content_params) { { heading: "A new level" } }

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(content, :heading) }
    it { expect { action }.to change(Katalyst::Content::Content, :count).by(1) }

    it "sets title in the new link version" do
      action
      expect(Katalyst::Content::Content.last.heading).to eq("A new level")
    end

    context "with invalid params" do
      let(:content_params) { { heading: "" } }

      it { is_expected.to be_unprocessable }
    end
  end
end
