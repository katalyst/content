# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/ExampleLength
RSpec.describe Katalyst::Content::MigrateHtml do
  subject(:migration) { described_class.new }

  let(:page) { create(:page) }

  it { is_expected.to be_success }

  it "can migrate plain text" do
    content = <<~HTML
      Some plain text without any tags.
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(heading:       "Some plain text without any tags",
                      heading_style: "none",
                      content:       match_html(content)),
    )
  end

  it "can migrate a paragraph with inline tags" do
    content = <<~HTML
      <p>Some <strong>rich text</strong> with <em>inline tags</em>.</p>
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(heading:       "Some rich text with inline tags",
                      heading_style: "none",
                      content:       match_html(content)),
    )
  end

  it "can migrate multiple block level tags" do
    content = <<~HTML
      <p>Some <strong>rich text</strong> with <em>inline tags</em>.</p>
      <p>Some <strong>more</strong> content.</p>
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(heading:       "Some rich text with inline tags",
                      heading_style: "none",
                      content:       match_html(content)),
    )
  end

  it "can migrate content with titles" do
    content = <<~HTML
      <h3>This is a content title</h3>
      <h4>This is a trix title</h4>
      <p>Some <strong>more</strong> content.</p>
      <h3>This is a new content block</h3>
      <p>Some <strong>more</strong> content.</p>
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(heading:       "This is a content title",
                      heading_style: "default",
                      content:       match_html(<<~HTML),
                        <h4>This is a trix title</h4>
                        <p>Some <strong>more</strong> content.</p>
                      HTML
                     ),
      have_attributes(heading: "This is a new content block",
                      content: match_html(<<~HTML),
                        <p>Some <strong>more</strong> content.</p>
                      HTML
                     ),
    )
  end

  it "can migrate content with section" do
    content = <<~HTML
      <h2>This is a section title</h2>
      <p>Some content.</p>
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(type:          "Katalyst::Content::Section",
                      heading:       "This is a section title",
                      heading_style: "default",
                      depth:         0),
      have_attributes(heading_style: "none",
                      content:       match_html(<<~HTML),
                        <p>Some content.</p>
                      HTML
                      depth:         1),
    )
  end
end
# rubocop:enable RSpec/ExampleLength
