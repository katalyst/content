# frozen_string_literal: true

module Katalyst
  module Content
    module TableHelper
      mattr_accessor(:sanitizer, default: Rails::HTML5::Sanitizer.safe_list_sanitizer.new)
      mattr_accessor(:scrubber)

      # Normalize table content and render to an HTML string (un-sanitised).
      #
      # @param table [Katalyst::Content::Table]
      # @param heading [Boolean] whether to add the heading as a caption
      # @return [String] un-sanitised HTML as text
      def normalize_content_table(table, heading: true)
        TableNormalizer.new(table, heading:).to_html
      end

      # Sanitize table content and render to an HTML string (un-sanitised).
      #
      # @param content [String] un-sanitised HTML as text
      # @return [ActiveSupport::SafeBuffer] sanitised HTML
      def sanitize_content_table(content)
        sanitizer.sanitize(
          content,
          tags:       content_table_allowed_tags,
          attributes: content_table_allowed_attributes,
          scrubber:,
        ).html_safe # rubocop:disable Rails/OutputSafety
      end

      private

      def content_table_allowed_tags
        Katalyst::Content.config.table_sanitizer_allowed_tags
      end

      def content_table_allowed_attributes
        Katalyst::Content.config.table_sanitizer_allowed_attributes
      end

      # rubocop:disable Rails/HelperInstanceVariable
      class TableNormalizer
        attr_reader :node, :heading_rows, :heading_columns

        delegate_missing_to :@node

        def initialize(table, heading: true)
          @table   = table
          @heading = heading

          root  = ActionText::Fragment.from_html(table.content&.body&.to_html || "").source
          @node = root.name == "table" ? root : root.at_css("table")

          return unless @node

          @heading_rows = @table.heading_rows.clamp(0..css("tr").length)
          @heading_columns = @table.heading_columns.clamp(0..)
        end

        def set_caption!
          return if at_css("caption")

          prepend_child("<caption>#{@table.heading}</caption>")
        end

        # move cells between thead and tbody based on heading_rows
        def set_header_rows!
          rows = node.css("tr")

          if heading_rows > thead.css("tr").count
            rows.slice(0, heading_rows).reject { |row| row.parent == thead }.each do |row|
              thead.add_child(row)
            end
          else
            rows.slice(heading_rows, rows.length).reject { |row| row.parent == tbody }.reverse_each do |row|
              tbody.prepend_child(row)
            end
          end
        end

        # convert cells between th and td based on heading_columns
        def set_header_columns!
          matrix = []

          css("tr").each_with_index do |row, y|
            row.css("td, th").each_with_index do |cell, x|
              # step right until we find an empty cell
              x += 1 until matrix.dig(y, x).nil?

              # update the type of the cell based on the heading configuration
              set_cell_type!(cell, y, x)

              # record the coordinates that this cell occupies in the matrix
              # e.g. colspan=2 rowspan=3 would occupy 6 cells
              row_range(cell, y).each do |ty|
                col_range(cell, x).each do |tx|
                  matrix[ty] ||= []
                  matrix[ty][tx] = cell.text
                end
              end
            end
          end
        end

        def set_cell_type!(cell, row, col)
          cell.name = col < heading_columns || row < heading_rows ? "th" : "td"
        end

        def to_html
          return "" if @node.nil?

          set_caption! if @heading && @table.heading.present? && !@table.heading_none?
          set_header_rows!
          set_header_columns!

          @node.to_html
        end

        private

        def thead
          @thead ||= at_css("thead") || tbody.add_previous_sibling("<thead>").first
        end

        def tbody
          @tbody ||= at_css("tbody") || add_child("<tbody>").last
        end

        def col_range(cell, from)
          colspan = cell.attributes["colspan"]&.value&.to_i || 1
          (from..).take(colspan)
        end

        def row_range(cell, from)
          rowspan = cell.attributes["rowspan"]&.value&.to_i || 1
          (from..).take(rowspan)
        end
      end

      # rubocop:enable Rails/HelperInstanceVariable
    end
  end
end
