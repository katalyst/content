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

  it "can migrate tables" do
    content = <<~HTML
      <h2>This is a section title</h2>
      <p>Some content.</p>
      <table>
        <tr>
          <td>Some content</td>
        </tr>
      </table>
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
      have_attributes(type:          "Katalyst::Content::Table",
                      heading_style: "none",
                      content:       match_html(<<~HTML),
                                          <table>
                          <tr>
                            <td>Some content</td>
                          </tr>
                        </table>
                      HTML
                      depth:         1),
    )
  end

  # rubocop:disable RSpec/MultipleExpectations
  it "can migrate satac tables" do
    content = <<~HTML
            <table border="1" cellpadding="1" cellspacing="1" style="width:100%;">
        <thead>
          <tr>
            <th colspan="3" scope="col" style="text-align: left;">New student contribution amounts in 2023</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <strong>Funding Cluster</strong>
            </td>
            <td>
              <strong>Fields</strong>
            </td>
            <td>
              <strong>2023 maximum student contribution amount (per EFTSL)</strong>
            </td>
          </tr>
          <tr>
            <td>
              <strong>Funding cluster 1</strong>
            </td>
            <td>Law, accounting, administration, economics, commerce, communications, society and culture</td>
            <td>$15,142</td>
          </tr>
          <tr>
            <td colspan="1" rowspan="2">
              <strong>Funding cluster 2</strong>
            </td>
            <td>Education, Postgraduate Clinical Psychology, English, Mathematics or Statistics</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Allied Health, Other Health, Built Environment, Computing, Visual and Performing Arts, Professional Pathway Psychology or Professional Pathway Social Work</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <td colspan="1" rowspan="2">
              <strong>Funding cluster 3</strong>
            </td>
            <td>Nursing, Indigenous and Foreign Languages</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Engineering, Surveying, Environmental Studies or Science</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <td colspan="1" rowspan="3">
              <strong>Funding cluster 4</strong>
            </td>
            <td>Agriculture</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Pathology</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <td>Medicine, Dentistry or Veterinary Science</td>
            <td>$11,800</td>
          </tr>
        </tbody>
      </table>
    HTML
    migration.call(page, content)
    expect(page.published_items).to contain_exactly(
      have_attributes(type:          "Katalyst::Content::Table",
                      heading:       "New student contribution amounts in 2023",
                      heading_style: "default"),
    )
    helper = Object.new.extend(Katalyst::Content::TableHelper)
    rendered = helper.sanitize_content_table(helper.normalize_content_table(page.published_items.first))
    expect(rendered).to match_html(<<~HTML)
      <table>
        <caption>New student contribution amounts in 2023</caption>
        <thead>
         <tr>
            <th>Funding Cluster</th>
            <th>Fields</th>
            <th>2023 maximum student contribution amount (per EFTSL)</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th>Funding cluster 1</th>
            <td>Law, accounting, administration, economics, commerce, communications, society and culture</td>
            <td>$15,142</td>
          </tr>
          <tr>
            <th colspan="1" rowspan="2">Funding cluster 2</td>
            <td>Education, Postgraduate Clinical Psychology, English, Mathematics or Statistics</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Allied Health, Other Health, Built Environment, Computing, Visual and Performing Arts, Professional Pathway Psychology or Professional Pathway Social Work</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <th colspan="1" rowspan="2">Funding cluster 3</th>
            <td>Nursing, Indigenous and Foreign Languages</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Engineering, Surveying, Environmental Studies or Science</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <th colspan="1" rowspan="3">Funding cluster 4</td>
            <td>Agriculture</td>
            <td>$4,124</td>
          </tr>
          <tr>
            <td>Pathology</td>
            <td>$8,301</td>
          </tr>
          <tr>
            <td>Medicine, Dentistry or Veterinary Science</td>
            <td>$11,800</td>
          </tr>
        </tbody>
      </table>
    HTML
  end
  # rubocop:enable RSpec/MultipleExpectations
end
# rubocop:enable RSpec/ExampleLength
