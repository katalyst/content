# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::TablesController do
  subject { action && response }

  let(:container) { create(:page) }
  let(:default_item_params) { { type: item.class.name, container_id: container.id, container_type: "Page" } }
  let(:item) { build(:katalyst_content_table, container:) }
  let(:item_params) { default_item_params }

  describe "POST /tables" do
    let(:action) { post katalyst_content.tables_path, params: { item: item_params }, as: :turbo_stream }
    let(:item_params) { attributes_for(:katalyst_content_table).merge(default_item_params) }

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(Katalyst::Content::Content, :count) }

    context "with invalid params" do
      let(:item) { build(:katalyst_content_table, container:) }
      let(:item_params) { attributes_for(:katalyst_content_table, content: "").merge(default_item_params) }

      it { is_expected.to be_unprocessable }
    end
  end

  describe "PATCH /tables/:id" do
    let(:action) { patch katalyst_content.table_path(item), params: { item: item_params }, as: :turbo_stream }
    let!(:item) { create(:katalyst_content_table, container:) }

    it { is_expected.to be_successful }

    it { expect { action }.not_to change(item, :updated_at) }
    it { expect { action }.not_to change(Katalyst::Content::Table, :count) }

    context "with invalid params" do
      let(:item_params) { { content: "" }.merge(default_item_params) }

      it { is_expected.to be_unprocessable }
    end
  end
end
