# frozen_string_literal: true

module Katalyst
  module Content
    module Tables
      class Importer
        include ActiveModel::Model

        delegate :config, to: Katalyst::Content::Config

        delegate_missing_to :@node

        attr_reader :table

        # Update a table from an HTML5 fragment and apply normalisation rules.
        #
        # @param table [Katalyst::Content::Table] the table to update
        # @param value [Nokogiri::XML::Node, ActionText::RichText, String] the provided HTML fragment
        def self.call(table, value)
          new(table).call(wrap(value))
        end

        def self.wrap(value)
          case value
          when Nokogiri::XML::Node
            value
          when ActionText::RichText
            # clone body to avoid modifying the original
            Nokogiri::HTML5.fragment(value.body.to_html)
          else
            Nokogiri::HTML5.fragment(value.to_s)
          end
        end

        def initialize(table)
          super()

          @table = table
        end

        def call(fragment)
          @node = fragment.name == "table" ? fragment : fragment.at_css("table")

          unless @node&.name == "table"
            table.content.body = nil
            return self
          end

          # Convert b and i to strong and em
          normalize_emphasis!

          # Convert `td > strong` to th headings
          promote_header_cells!

          # Promote any rows with only <th> cells to <thead>
          # This captures the pattern where a table has a header row but its
          # in the tbody instead of the thead
          promote_header_rows!

          # Promote first row to caption if it only has one cell.
          # This captures the pattern where a table has as single cell that spans
          # the entire width of the table, and is used as a heading.
          promote_header_row_caption! if header_row_caption?

          # Update the table heading with the caption, if present, and remove from table
          set_heading! if caption?

          # Update the table's content with the normalized HTML.
          table.content.body = to_html

          table
        end

        def caption?
          at_css("caption")&.text&.present?
        end

        def header_row_caption?
          !at_css("caption") &&
            (tr = at_css("thead > tr:first-child"))&.elements&.count == 1 &&
            (tr.elements.first.attributes["colspan"]&.value&.to_i&.> 1)
        end

        def normalize_emphasis!
          traverse do |node|
            case node.name
            when "b"
              node.name = "strong"
            when "i"
              node.name = "em"
            else
              node
            end
          end
        end

        def promote_header_cells!
          css("td:has(strong)").each { |cell| promote_cell_to_heading!(cell) }
        end

        # Converts a `td > strong` cell to a `th` cell by updating the cell name
        # and replacing the cell's content with the strong tag's content.
        def promote_cell_to_heading!(cell)
          strong = cell.at_css("strong")

          return unless cell.text.strip == strong.text.strip

          cell.name = "th"

          # remove strong by promoting its children
          strong.before(strong.children)
          strong.remove
        end

        def promote_header_rows!
          css("tbody > tr").each do |tr|
            break unless tr.elements.all? { |td| td.name == "th" }

            promote_row_to_head!(tr)
          end
        end

        # Moves a row from <tbody> to <thead>.
        # If the table doesn't have a <thead>, one will be created.
        def promote_row_to_head!(row)
          at_css("tbody").before("<thead></thead>") unless at_css("thead")
          at_css("thead") << row
        end

        # Promotes the first row to a caption if it only has one cell.
        def promote_header_row_caption!
          tr   = at_css("thead > tr:first-child")
          cell = tr.elements.first
          tr.remove
          thead = at_css("thead")
          thead.before("<caption></caption>")
          thead.remove if thead.elements.empty?
          at_css("caption").inner_html = cell.inner_html.strip
        end

        # Set heading from caption and remove the caption from the table.
        def set_heading!
          caption = at_css("caption")
          table.heading       = caption.text.strip
          table.heading_style = "default"
          caption.remove
        end
      end
    end
  end
end
