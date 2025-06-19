# frozen_string_literal: true

RSpec.shared_examples "a item" do
  it { is_expected.to be_valid }

  it { is_expected.to belong_to(:container).required }

  it { is_expected.to validate_presence_of(:heading) }

  it "defines heading style enum" do
    expect(item).to define_enum_for(:heading_style)
                      .with_values(Katalyst::Content.config.heading_styles)
                      .with_prefix(:heading)
  end

  it "defines theme enum" do
    expect(item).to define_enum_for(:theme)
                      .backed_by_column_of_type(:string)
                      .with_values(Katalyst::Content.config.themes.index_with(&:itself))
                      .with_prefix(:theme)
                      .with_default("")
  end

  describe "#to_plain_text" do
    context "when item is not visible" do
      before { item.visible = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
