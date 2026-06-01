# frozen_string_literal: true

module Katalyst
  module Content
    class Layout < Item
      def to_plain_text
        return unless visible?

        [super, *children.filter_map(&:to_plain_text)].join("\n").presence
      end
    end
  end
end
