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

  it { is_expected.to validate_inclusion_of(:theme).in_array(Katalyst::Content.config.themes).allow_blank }

  describe "#to_plain_text" do
    context "when item is not visible" do
      before { item.visible = false }

      it { is_expected.to have_attributes(to_plain_text: nil) }
    end
  end
end
