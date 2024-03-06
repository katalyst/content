# frozen_string_literal: true

require "rails_helper"

RSpec.describe Katalyst::Content::Table do
  subject(:table) { build(:katalyst_content_table, container: page) }

  let(:page) { create(:page) }

  it { is_expected.to be_valid }
  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:content) }

  it "sets heading from table caption" do
    table.validate
    expect(table).to have_attributes(heading: "Contacts")
  end

  describe "#to_plain_text" do
    it { is_expected.to have_attributes(to_plain_text: table.content.to_plain_text) }

    context "when item is not visible" do
      before { table.visible = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe "#content=" do
    it "loads factory default without modifications" do
      expect(table.content.body.to_html).to match_html(<<~HTML)
        <table>
          <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
          </tr>
          </thead>
          <tbody>
          <tr>
            <td>John Doe</td>
            <td>john.doe@example.com</td>
          </tr>
          </tbody>
        </table>
      HTML
    end

    context "with a caption" do
      let(:table) { build(:katalyst_content_table, content: <<~HTML) }
        <table><caption>Captioned</caption><tr><th>Name</th></tr><tr><td>John Doe</td></tr></table>
      HTML

      it "parses caption as a heading" do
        expect(table).to have_attributes(
          heading:         "Captioned",
          heading_style:   "default",
          content:         match_html(<<~HTML),
            <table><thead><tr><th>Name</th></tr></thead><tbody><tr><td>John Doe</td></tr></tbody></table>
          HTML
          heading_rows:    1,
          heading_columns: 0,
        )
      end
    end

    context "with td > strong headings" do
      let(:table) { build(:katalyst_content_table, content: <<~HTML) }
        <table><tr><td><strong>Name</strong></td></tr><tr><td>John Doe</td></tr></table>
      HTML

      it "creates a thead from td > strong row" do
        expect(table.content.body.to_html).to match_html(<<~HTML)
          <table>
            <thead>
            <tr>
              <th>Name</th>
            </tr>
            </thead>
            <tbody>
            <tr>
              <td>John Doe</td>
            </tr>
            </tbody>
          </table>
        HTML
      end
    end

    context "with colspan heading row" do
      let(:table) { build(:katalyst_content_table, content: <<~HTML) }
        <table>
          <tr><th colspan="2">Contacts</th></tr>
          <tr><th>Name</th><th>Email</th></tr>
          <tr><td>John Doe</td><td>john@example.com</td></tr>
        </table>
      HTML

      it "promotes heading row to component heading" do
        expect(table.heading).to eq("Contacts")
      end

      it "removes heading row" do
        expect(table.content.body.to_html).to match_html(<<~HTML)
          <table>
            <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
            </tr>
            </thead>
            <tbody>
            <tr>
              <td>John Doe</td>
              <td>john@example.com</td>
            </tr>
            </tbody>
          </table>
        HTML
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe "#dup" do
    it "preserves page association on dup" do
      expect(table.dup).to have_attributes(table.attributes.slice("parent_id", "parent_type"))
    end

    it "copies rich text" do
      copy = table.dup
      expect(copy.content).to be_new_record
    end

    it "preserves rich text content" do
      copy = table.dup
      expect(copy.content.body).to eq(table.content.body)
    end
  end
end
