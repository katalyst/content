# frozen_string_literal: true

# rubocop:disable Metrics/PerceivedComplexity
module Katalyst
  module Content
    class MigrateHtml
      include ActiveModel::Model

      SUPPORTED_ROOT_TAGS = %w[br h4 h5 h6 hr ol p text ul].freeze
      SUPPORTED_TRIX_TAGS = %w[h4 h5 h6 hr ol p text ul li b br em a strong span].freeze

      attr_reader :model

      def self.call(model, content)
        new.call(model, content)
      end

      def call(model, content)
        @model = model
        @items = []
        @depth = 0

        root = Nokogiri::HTML5.fragment(content)

        root.children.each do |node|
          case node.name
          when "h2"
            add_section_node(heading: node.text, heading_style: "default")
          when "h3"
            add_content_node(heading: node.text, heading_style: "default")
          when "br", "h4", "h5", "h6", "hr", "ol", "p", "text", "ul"
            append_html(node)
          else
            errors.add(:base, "contains invalid tag #{node.name}")
          end
        end

        @items.each do |item|
          if item.is_a?(Katalyst::Content::Content) && item.heading.blank?
            item.destroy
          end
        end

        unless @model.save
          errors.copy!(@model)

          return self
        end

        @model.items_attributes = @items.map.with_index do |item, index|
          { id: item.id, index:, depth: item.depth }
        end

        @model.publish!

        self
      end

      def success?
        errors.empty?
      end

      private

      def build(type:, **)
        @last = item = @model.items.build(
          type:,
          **defaults,
          **,
        )
        @items << item
        item
      end

      def add_section_node(heading:, **)
        @depth = 0
        item = build(
          type:    Katalyst::Content::Section,
          heading:,
          **defaults,
          **,
        )
        @depth = 1
        item
      end

      def add_content_node(**)
        build(
          type: Katalyst::Content::Content,
          **defaults,
          **,
        )
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
