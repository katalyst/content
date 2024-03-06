# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExampleLength
RSpec.describe Katalyst::Content::TableHelper do
  subject(:helper) { Object.new.extend(described_class) }

  let(:table) { build(:katalyst_content_table, heading_style: "default") }

  let(:rendered) do
    helper.sanitize_content_table(helper.normalize_content_table(table))
  end

  it "adds caption when rendering" do
    expect(rendered).to match_html(<<~HTML)
      <table>
        <caption>Contacts</caption>
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

  context "when heading is not visible" do
    let(:table) { build(:katalyst_content_table, heading_style: "none", content: <<~HTML) }
      <table><tr><th>Name</th></tr><tr><td>John Doe</td></tr></table>
    HTML

    it "doesn't add a caption" do
      expect(rendered).to match_html(<<~HTML)
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
end
# rubocop:enable RSpec/ExampleLength
