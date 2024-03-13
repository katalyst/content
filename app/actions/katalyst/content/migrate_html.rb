# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity
module Katalyst
  module Content
    module MigrateHtml
      extend ActiveSupport::Concern

      SUPPORTED_ROOT_TAGS = %w[br h4 h5 h6 hr ol p text ul].freeze
      SUPPORTED_TRIX_TAGS = %w[h4 h5 h6 hr ol p text ul li b br em a strong span].freeze

      def add_html(content)
        root = Nokogiri::HTML5.fragment(content)

        root.children.each do |node|
          add_node(node)
        end

        @items.each do |item|
          if item.is_a?(Katalyst::Content::Content) && item.heading.blank?
            item.destroy
          end
        end

        self
      end

      def add_node(node)
        case node.name
        when "h2"
          if node.text.strip.present?
            add_section_node(heading: node.text.strip, heading_style: "default")
          else
            add_section_node(heading: "Empty section", heading_style: "none")
          end
        when "h3"
          add_content_node(heading: node.text, heading_style: "default")
        when "br", "h4", "h5", "h6", "hr", "ol", "p", "text", "ul"
          append_html(node)
        when "table"
          add_table_node(node)
        else
          errors.add(:base, "contains invalid tag #{node.name}")
        end
      end

      def append_html(node)
        content = last_content_node

        node.traverse do |n|
          errors.add(:base, "contains invalid tag #{n.name}") unless SUPPORTED_TRIX_TAGS.include?(n.name)
        end

        content.content = if content.content.present?
                            content.content.read_attribute_before_type_cast(:body) + node.to_html
                          else
                            node.to_html
                          end

        content.heading ||= heading_for(content.content)

        content
      end

      def build(type:, **)
        @last = item = @model.items.build(
          type:,
          **defaults,
          **,
        )
        @items << item
        item
      end

      delegate :config, to: Katalyst::Content::Config

      private

      def add_section_node(heading:, **)
        heading = heading.strip

        @depth = 0
        item   = build(
          type:          Katalyst::Content::Section,
          heading:       heading.presence || "Blank",
          heading_style: heading.present? ? "default" : "none",
          **defaults,
          **,
        )
        @depth = 1
        item
      end

      IGNORED_TABLE_ATTRIBUTES = %w[align border cellpadding cellspacing scope style width height].freeze

      def add_table_node(node, **)
        table = build(
          type:    Katalyst::Content::Table,
          content: node,
          **defaults,
          **,
        )

        errors.copy!(table.errors)

        table.heading ||= heading_for(table)

        table
      end

      def add_content_node(**)
        build(
          type: Katalyst::Content::Content,
          **defaults,
          **,
        )
      end

      def last_content_node(**)
        if @last.is_a?(Katalyst::Content::Content)
          @last
        else
          add_content_node(**)
        end
      end

      def heading_for(action_text)
        action_text.to_plain_text.match(/([\w\s]+)/)&.match(1)&.strip
      end

      def defaults
        {
          background: Katalyst::Content::Config.backgrounds.first,
          visible:    true,
          depth:      @depth,
        }
      end
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity
